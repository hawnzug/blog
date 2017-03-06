stack exec site rebuild
rsync -r -a -vv -e "ssh -p 27989" --delete _site/ root@23.83.238.25:/usr/share/nginx/blog/
