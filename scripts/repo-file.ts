import * as path from "node:path";
import { fileURLToPath } from "node:url";

export const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

/** リポジトリ相対パスを絶対パスにする。 */
export const repoFile = (...segments: string[]): string => path.join(repoRoot, ...segments);
