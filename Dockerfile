ARG DOCKER_BASE_IMAGE_PREFIX
ARG DOCKER_BASE_IMAGE_NAMESPACE=pythonpackagesonalpine
ARG DOCKER_BASE_IMAGE_NAME=python-visualization-alpine
ARG DOCKER_BASE_IMAGE_TAG=matplotlib-alpine
FROM ${DOCKER_BASE_IMAGE_PREFIX}${DOCKER_BASE_IMAGE_NAMESPACE}/${DOCKER_BASE_IMAGE_NAME}:${DOCKER_BASE_IMAGE_TAG}

ARG FIX_ALL_GOTCHAS_SCRIPT_LOCATION
ARG ETC_ENVIRONMENT_LOCATION
ARG CLEANUP_SCRIPT_LOCATION

# Depending on the base image used, we might lack wget/curl/etc to fetch ETC_ENVIRONMENT_LOCATION.
ADD $FIX_ALL_GOTCHAS_SCRIPT_LOCATION .
ADD $CLEANUP_SCRIPT_LOCATION .

RUN set -o allexport \
    && . ./fix_all_gotchas.sh \
    && set +o allexport \
    && apk add --no-cache py3-scipy \
    && apk add --no-cache tesseract-ocr imagemagick \
    && apk add --no-cache --virtual .build-deps g++ make python3-dev py3-numpy-dev lapack-dev blas-dev zlib-dev jpeg-dev musl-dev \
    && pip install scikit-image \
    && python -c "import skimage" \
    && apk del --no-cache .build-deps \
    && apk add --no-cache py3-numpy \
    && python -c "import skimage" \
    && . ./cleanup.sh

