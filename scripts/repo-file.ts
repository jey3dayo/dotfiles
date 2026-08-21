import * as path from "node:path";
import { fileURLToPath } from "node:url";

/** `scripts/` の親。テストはこのモジュール経由でリポジトリ内パスを取る。 */
export const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

/** リポジトリルートからの相対パスを絶対パスにする。 */
export const repoFile = (...segments: string[]): string => path.join(repoRoot, ...segments);
