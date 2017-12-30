stack exec site rebuild
rsync -r -a -vv -e "ssh -p 28262" --delete _site/ root@104.194.77.191:/usr/share/nginx/blog/
