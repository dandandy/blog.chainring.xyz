publish: render
	aws s3 sync ./public s3://blog.chainring.xyz --acl public-read

update-theme:
	git submodule update --remote --rebase

website:
	aws s3 website s3://blog.chainring.xyz --index-document index.html --error-document index.html

render:
	hugo