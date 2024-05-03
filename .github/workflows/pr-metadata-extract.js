import { getPrYamlBlock, parseYamlToJSON } from "./metadata-utils.js";

// todo.. context needs refactoring. the PR number will come from the commit..
export async function extractPrMetadata({ github, context, core }) {
  try {
    const yamlBlock = await getPrYamlBlock(github, context);
    const metadata = parseYamlToJSON(yamlBlock);
    return metadata;
  } catch (error) {
    core.setFailed(error.message);
  }
}
