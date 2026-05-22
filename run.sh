#!/bin/bash

set -eux

pip install hf-transfer --break-system-packages

export HF_HUB_ENABLE_HF_TRANSFER=1

CONVERT_ARGS=()
if [[ "${TRUST_REMOTE_CODE:-false}" == "true" ]]; then
    echo "TRUST_REMOTE_CODE=true: passing --trust-remote-code to convert_hf_to_gguf.py"
    CONVERT_ARGS+=(--trust-remote-code)
else
    echo "TRUST_REMOTE_CODE=${TRUST_REMOTE_CODE:-false}: running without --trust-remote-code"
fi

./convert_hf_to_gguf.py --outfile "${MODEL_NAME}-F16.gguf" --outtype auto --remote "${SRC_REPO}" "${CONVERT_ARGS[@]}" 

rm -rf "$HOME/.cache/huggingface"

huggingface-cli upload "${DST_REPO}" "${MODEL_NAME}-F16.gguf"

# MODES=(
#     "IQ3_M"
#     "IQ3_S"
#     "IQ3_XS"
#     "IQ4_NL"
#     "IQ4_XS"
#     "Q2_K"
#     "Q3_K"
#     "Q3_K_L"
#     "Q3_K_M"
#     "Q3_K_S"
#     "Q4_0"
#     "Q4_1"
#     "Q4_K"
#     "Q4_K_M"
#     "Q4_K_S"
#     "Q5_0"
#     "Q5_1"
#     "Q5_K"
#     "Q5_K_M"
#     "Q5_K_S"
#     "Q6_K"
#     "Q8_0"
# )

MODES=(
    "IQ3_XS"
    "IQ4_XS"
)


for MODE in "${MODES[@]}"; do
    ./llama-quantize "${MODEL_NAME}-F16.gguf" "${MODEL_NAME}-$MODE.gguf" "$MODE"
    huggingface-cli upload "${DST_REPO}" "${MODEL_NAME}-$MODE.gguf"
    rm -f "${MODEL_NAME}-$MODE.gguf"
done
