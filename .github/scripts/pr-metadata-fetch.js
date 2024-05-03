import { fetchPrYmlBlock, parseYmlToJSON } from "./metadata-utils.js";

export async function fetchPrMetadata({ github, context, core }) {
  try {
    const ymlBlock = await fetchPrYmlBlock(github, context);
    const metadata = parseYmlToJSON(ymlBlock);
    return metadata;
  } catch (error) {
    core.setFailed(error.message);
  }
}