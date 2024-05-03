const METADATA_TEMPLATE = {
  "semver-level": ["major", "minor", "patch"],
  "needs-infra-changes": ["true", "false"],
};

function parseYmlToJSON(yamlString) {
  const lines = yamlString.split(/\r\n|\r|\n/g);
  const yamlObj = {};

  lines.forEach((line) => {
    const [key, value] = line
      .split("#")[0] // removes any inline comments
      .split(":")
      .map((s) => s.trim());

    if (key && value) {
      yamlObj[key] = value;
    }
  });

  return yamlObj;
}

function getPrYmlBlock(description) {
  const yamlBlockRegex = new RegExp(/```yml([\s\S]*?)```/s);
  const yamlBlock = yamlBlockRegex.exec(description);

  if (!yamlBlock)
    throw new Error("Metadata block not found in PR description.");

  return yamlBlock[1];
}

async function fetchPrYmlBlock(github, context) {
  const { owner, repo, number } = context.issue;

  const { data } = await github.rest.pulls.get({
    owner,
    repo,
    pull_number: number,
  });

  return getPrYmlBlock(data.body);
}

function validateKeyValue(key, value) {
  const expectedValues = METADATA_TEMPLATE[key];
  if (!expectedValues) {
    return false;
  }
  return expectedValues.includes(value);
}

function validate(metadata) {
  const validationResult = Object.entries(METADATA_TEMPLATE).reduce(
    (acc, [templateKey, templateValue]) => {
      if (!(templateKey in metadata)) {
        acc.missingKey.push(templateKey);
      } else if (!validateKeyValue(templateKey, metadata[templateKey])) {
        acc.invalidValue.push({
          key: templateKey,
          value: metadata[templateKey],
          expectedValues: templateValue.join(", "),
        });
      }
      return acc;
    },
    { missingKey: [], invalidValue: [] }
  );

  if (
    validationResult.missingKey.length === 0 &&
    validationResult.invalidValue.length === 0
  ) {
    return true;
  }

  let errorMessage =
    "The metadata block of the PR description is invalid for the following reason(s):\n";

  if (validationResult.missingKey.length > 0) {
    errorMessage += `- Missing the key(s): ${validationResult.missingKey.join(
      ", "
    )}.\n`;
  }

  if (validationResult.invalidValue.length > 0) {
    const invalidValueError = validationResult.invalidValue
      .map(
        ({ key, value, expectedValues }) =>
          `- The key '${key}' has an invalid value of '${value}'. Expected one of: ${expectedValues}.`
      )
      .join("\n");

    errorMessage += invalidValueError;
  }
  throw new Error(errorMessage);
}

export {
  METADATA_TEMPLATE,
  parseYmlToJSON,
  fetchPrYmlBlock,
  getPrYmlBlock,
  validate,
};
