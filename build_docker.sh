# !/bin/sh

usage() {
    echo "Usage: build_docker [-e node env] [-v version] [-h]"
    echo "- node env: development (default), production"
}

# parses command line arguments
while getopts "he:v:" opt; do
    case $opt in
        h)
            usage
            exit 0
            ;;
        e)
            node_env=$OPTARG
            ;;
        v)
            version=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

node_env=${node_env:-development}

export NODE_ENV=${node_env}
export BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
export GIT_COMMIT=$(git rev-parse HEAD)

GIT_TAG=
if [ -n "$version" ]; then
  GIT_TAG=${version}
fi

if [ -z "$GIT_TAG" ]; then
  GIT_TAG=$(git describe --exact-match --tags HEAD)
fi

if [ -n "$GIT_TAG" ]; then
  export GIT_TAG=${GIT_TAG}
fi

export VERSION=${GIT_TAG:-latest}
echo "Image tag: ${VERSION}"

echo "Building docker image with the following arguments"
echo "NODE_ENV=${NODE_ENV}"
echo "BUILD_DATE=${BUILD_DATE}"
echo "GIT_COMMIT=${GIT_COMMIT}"
echo "GIT_TAG=${GIT_TAG}"

docker compose -f docker-compose.build.yml build excalidraw-room
