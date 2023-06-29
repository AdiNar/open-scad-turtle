inotifywait -m -r -e modify . |
	while read file_path file_event file_name; do
		clear
		openscad tests.scad -o /dev/null --export-format asciistl
	done
