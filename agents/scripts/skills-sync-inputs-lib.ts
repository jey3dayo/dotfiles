export interface SourceEntry {
  name: string;
  url: string | null;
  flake: boolean | null;
}

const AGENT_BLOCK_HEADER = [
  "    # Agent-skills external sources (flake = false: raw git repos)",
  "    # NOTE: These must be manually kept in sync with nix/agent-skills-sources.nix",
  "    #       Flake spec requires literal inputs - dynamic generation not allowed",
  "    #       agent-skills-sources.nix remains the SSoT for baseDir and selection metadata",
];
const AGENT_BLOCK_FOOTER = ["    # END Agent-skills external sources"];

export const countChar = (str: string, char: string): number => {
  let count = 0;
  for (const ch of str) {
    if (ch === char) count += 1;
  }
  return count;
};

export const stripComments = (line: string): string => line.replace(/#.*/, "");

export const extractSources = (content: string): SourceEntry[] => {
  const lines = content.split(/\r?\n/);
  let depth = 0;
  const sources: SourceEntry[] = [];
  let current: SourceEntry | null = null;

  for (let i = 0; i < lines.length; i += 1) {
    const raw = lines[i];
    const sanitized = stripComments(raw);
    if (depth === 1 && !current) {
      const match = sanitized.match(/^\s*([A-Za-z0-9_-]+)\s*=\s*\{\s*$/);
      if (match) {
        current = { name: match[1], url: null, flake: null };
      }
    } else if (current) {
      const urlMatch = sanitized.match(/^\s*url\s*=\s*"([^"]+)"\s*;/);
      if (urlMatch) current.url = urlMatch[1];
      const flakeMatch = sanitized.match(/^\s*flake\s*=\s*(true|false)\s*;/);
      if (flakeMatch) current.flake = flakeMatch[1] === "true";
    }

    depth += countChar(sanitized, "{") - countChar(sanitized, "}");

    if (current && depth === 1) {
      sources.push(current);
      current = null;
    }
  }
  return sources;
};

export const buildAgentEntries = (sources: SourceEntry[]): string[] => {
  const lines: string[] = [];
  const sorted = sources
    .filter((source) => source.url)
    .slice()
    .sort((a, b) => a.name.localeCompare(b.name));

  for (const source of sorted) {
    const flakeValue = source.flake === true ? "true" : "false";
    lines.push(`    ${source.name} = {`);
    lines.push(`      url = "${source.url}";`);
    lines.push(`      flake = ${flakeValue};`);
    lines.push("    };");
  }
  return lines;
};

export const ensureInputsBlock = (
  lines: string[],
): {
  inputsStart: number;
  inputsEnd: number;
} => {
  let inputsStart = -1;
  let inputsEnd = -1;
  let depth = 0;

  for (let i = 0; i < lines.length; i += 1) {
    const sanitized = stripComments(lines[i]);
    if (inputsStart === -1 && /^\s*inputs\s*=\s*\{\s*$/.test(sanitized)) {
      inputsStart = i;
      depth = 1;
      continue;
    }
    if (inputsStart !== -1) {
      depth += countChar(sanitized, "{") - countChar(sanitized, "}");
      if (depth === 0) {
        inputsEnd = i;
        break;
      }
    }
  }

  if (inputsStart === -1 || inputsEnd === -1) {
    throw new Error("Failed to locate inputs block in flake.nix");
  }

  return { inputsStart, inputsEnd };
};

export const syncFlakeInputsFromSources = (
  sourceContent: string,
  flakeContent: string,
): string => {
  const sourceEntries = extractSources(sourceContent);
  const lines = flakeContent.split(/\r?\n/);
  const { inputsEnd } = ensureInputsBlock(lines);

  const startMarkerIndex = lines.findIndex((line) =>
    line.includes("# Agent-skills external sources"),
  );
  const endMarkerIndex = lines.findIndex((line) =>
    line.includes("# END Agent-skills external sources"),
  );

  const newBlock = [...AGENT_BLOCK_HEADER, ...buildAgentEntries(sourceEntries), ...AGENT_BLOCK_FOOTER];
  const updatedLines = lines.slice();

  if (startMarkerIndex !== -1) {
    const endIndex = endMarkerIndex !== -1 ? endMarkerIndex : inputsEnd - 1;
    updatedLines.splice(startMarkerIndex, endIndex - startMarkerIndex + 1, ...newBlock);
  } else {
    updatedLines.splice(inputsEnd, 0, ...newBlock);
  }

  const eol = flakeContent.includes("\r\n") ? "\r\n" : "\n";
  return updatedLines.join(eol);
};
