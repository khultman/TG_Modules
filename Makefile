
AWS_COMMON_CONFIG = "aws-common-configuration.tf"
AWS_DIRECTORIES = $(sort $(dir $(wildcard AWS_*/)))

VARIABLS_TF = "variabls.tf"

all: aws-symlinks

aws-symlinks:
	$(foreach dir, $(AWS_DIRECTORIES), pushd $(dir); ln -s ../$(AWS_COMMON_CONFIG) $(VARIABLS_TF); popd;)