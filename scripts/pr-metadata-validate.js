import { getPrYmlBlock, parseYmlToJSON, validate } from "./metadata-utils.js";

export function validatePrMetadata({ core, body }) {
  try {
    const ymlBlock = getPrYmlBlock(body);
    const metadata = parseYmlToJSON(ymlBlock);

    validate(metadata);
    core.info("Metadata is valid.");
  } catch (error) {
    core.setFailed(error.message);
  }
}
