infracost:
	infracost breakdown --path . --show-skipped

upload:
	date > date-in.local.txt
	slu s3 copy-to-s3 \
		--access-key $$(terraform output -raw write_access_key) \
		--secret-key $$(terraform output -raw write_secret_key) \
		--region eu-central-1 \
		--bucket-name $$(terraform output -raw bucket_name) \
		--source date-in.local.txt \
		--target date.txt

upload-fail:
	date > date-in.local.txt
	slu s3 copy-to-s3 \
		--access-key $$(terraform output -raw read_access_key) \
		--secret-key $$(terraform output -raw read_secret_key) \
		--region eu-central-1 \
		--bucket-name $$(terraform output -raw bucket_name) \
		--source date-in.local.txt \
		--target date.txt

download:
	slu s3 copy-from-s3 \
		--access-key $$(terraform output -raw read_access_key) \
		--secret-key $$(terraform output -raw read_secret_key) \
		--region eu-central-1 \
		--bucket-name $$(terraform output -raw bucket_name) \
		--source date.txt \
		--target date-out.local.txt
	cat date-out.local.txt

download-fail:
	slu s3 copy-from-s3 \
		--access-key $$(terraform output -raw write_access_key) \
		--secret-key $$(terraform output -raw write_secret_key) \
		--region eu-central-1 \
		--bucket-name $$(terraform output -raw bucket_name) \
		--source date.txt \
		--target date-out.local.txt

check:
	diff date-in.local.txt date-out.local.txt
