# gitcat

`gitcat` is a shell script for dumping the contents of a git repository's files, with smart handling for ignored files, deleted files, and binaries. It's designed to help you create code dumps for review or sharing. It also works outside of git repos!

## Features

- **Respects `.gitignore` and `.gitcatignore`**: Files ignored by either are skipped (when inside a git repo).
- **Handles deleted files**: Marks deleted-but-not-staged files with an emoji instead of erroring (when inside a git repo).
- **Binary file detection**: By default, binary files are not dumped; instead, a consistent emoji is shown for each type.
- **Custom ignore patterns**: Add a `.gitcatignore` file to further filter files for dumping (when inside a git repo).
- **Directory Depth**: Limit how deep the script searches into subdirectories.
- **Tree View**: Display a tree-like structure of the files instead of catting them.
- **Works outside git repos**: If not in a git repo, it will still function, ignoring the git-specific features.
- **Output**: Use `gitcat > my_dumped_code.txt` to create a code dump.

## Usage

1.  Make the script executable:

    ```sh
    chmod +x gitcat.sh
    ```
2.  You can copy the script to a directory in your `$PATH` (e.g., `/usr/local/bin`) to run it from anywhere:

    ```sh
    sudo cp gitcat.sh /usr/local/bin/gitcat
    ```

    Now you can run it simply with:

    ```sh
    gitcat > my_dumped_code.txt
    ```

## Options

-   `-b`: Force catting of binary files.
    ```sh
    gitcat -b > output.txt
    ```
-   `-d <num>`: Maximum directory depth.
    ```sh
    gitcat -d 3 > output.txt # Only goes 3 directories deep
    ```
-   `tree`: Display file tree.
    ```sh
    gitcat tree
    ```

## Example Output

```
===== src/main.py =====
print("Hello, world!")

📦 Binary file: logo.png
❌ Deleted: old_script.sh
```

## License

MIT
