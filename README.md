| ⚠ **WARNING**: This image is obsolete as [rubensa/ubuntu-tini-dev](https://github.com/rubensa/docker-ubuntu-tini-dev) now includes [Miniconda](https://docs.conda.io/en/latest/miniconda.html). |
| --- |

# Miniconda 3 image for local development

This image provides a Miniconda 3 environment useful for local development purposes.
This image is based on [rubensa/ubuntu-dev](https://github.com/rubensa/docker-ubuntu-dev) so you can set internal user (developer) UID and internal group (developers) GUID to your current UID and GUID by providing that info means of "-u" docker running option.

## Running

You can interactively run the container by mapping current user UID:GUID and working directory.

```
docker run --rm -it \
	--name "miniconda3-dev" \
	-v $(pwd):/home/developer/work \
	-w /home/developer/work \
	-u $(id -u $USERNAME):$(id -g $USERNAME) \
	--group-add conda \
	rubensa/miniconda3-dev
```

This way, any file created in the container initial working directory is written and owned by current host user:group launching the container (and the internal "conda" group is added to keep access to shared "/opt/conda" folder where conda is installed).
