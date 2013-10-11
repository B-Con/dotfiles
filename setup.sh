#!/usr/bin/env sh

#
# Install the dotfiles by symlinking files in $HOME to their corresponding file
# in the repository here. Back up the pre-exist file and then create symlinks 
# for each file (not directory). Installation also serves as re-installation.
#
# Uninstall by removing the symlinks. If the dotfile backup exists, restore
# from it.
#

###############################################################################
# Globals & Settings
###############################################################################

target_dir="$HOME"
repo_dir=/home/b-con/data/projects/my-code/dotfiles
bu_dir="$target_dir/.dotfile-backup"

###############################################################################
# Functions
###############################################################################

function get_repo_file_list() {
	# Kind of hacky. Note that this excludes all git files from this and
	# submodules.
	find . -type f | grep -v /.git/ | grep -v /setup.sh | grep -v /README.md | grep -v /LICENSE.md
}

# Take a directory as an argument and remove all the empty directories starting
# from the top.
function prune_empty_dirs() {
	dir_to_del="$1"
	rm_ret=0
	while [ $rm_ret -eq 0 ]; do
		rmdir "$dir_to_del" 2> /dev/null
		rm_ret=$?
		dir_to_del="`dirname "$dir_to_del"`"
	done
}

function install_file_list() {
	file_list="$1"
	while read -r file; do
		file="${file#./}"    # Strip off the leading "./" prefix.
		repo_path="$repo_dir/$file"
		bu_path="$bu_dir/$file"
		target_path="$target_dir/$file"

		echo "Installing \"$file\""

		echo -n "    [1/2] Backing up existing file: "
		# Don't backup symlinks, this allows us to install multiple times.
		if [ -f "$target_path" -a ! -L "$target_path" ]; then
			# Create the subdirectory for the backup, if needed.
			bu_sub_dir="`dirname "$bu_path"`"
			[ ! -d "$bu_sub_dir" ] && mkdir -p "$bu_sub_dir"
			mv -v "$target_path" "$bu_path"
		else
			echo "Nothing to backup"
		fi

		echo -n "    [2/2] Symlinking to repo: "
		if [ ! -f "$target_path" ]; then
			# Create the subdirectory for the symlink, if needed.
			target_sub_dir="`dirname "$target_path"`"
			[ ! -d "$target_sub_dir" ] && mkdir -p "$target_sub_dir"
			ln -vs "$repo_path" "$target_path"
		else
			# It must be a link. Don't touch it, to allow for
			# first-come-first-serve coexisting.
			echo "Skipping existing symlink"
			# To switch it to last-come takes precidence, comment the above
			# and use the below instead.
			# rm "$target_path"
			# ln -vs "$repo_path" "$target_path"
		fi
	done <<< "$file_list"
}

function uninstall_file_list() {
	file_list="$1"
	while read -r file; do
		file="${file#./}"
		bu_path="$bu_dir/$file"
		target_path="$target_dir/$file"
		
		echo "Uninstalling \"$file\""

		echo -n "    [1/2] Removing symlink: "
		# Only remove symlinks, since the install only added symlinks.
		if [ -f "$target_path" -a -L "$target_path" ]; then
			# Verify this symlink points to our repo.
			link_target="`readlink "$target_path"`"
			if [[ "$link_target" = "$repo_dir"* ]]; then
				rm -v "$target_path"
			else
				echo "Symlink preserved, it does not point into the repo"
			fi
		else
			echo "No symlink present, nothing to remove"
		fi

		echo -n "    [2/2] Restoring original file: "
		if [ -f "$target_path" ]; then
			echo "File still exists, no backup restored"
		else
			if [ -f "$bu_path" ]; then
				mv -v "$bu_path" "$target_path"
				# Remove empty directories in the backup path, including the 
				# backup path.
				prune_empty_dirs "`dirname "$bu_path"`"
			else
				echo "No backup to restore"
				# If the symlink is deleted and nothing is restored,
				# remove all the empty directories below the symlink. This 
				# prevents us from leaving empty directories that we probably
				# created at install. The disadvantage is that we may have
				# installed symlinks into pre-existing empty directories which
				# we are now deleting, but it seems unlikely and is better than
				# leaving litter behind.
				prune_empty_dirs "`dirname "$target_path"`"
			fi
		fi
	done <<< "$file_list"
}

###############################################################################
# Main execution
###############################################################################

case $1 in
	install)
		[ ! -d "$bu_dir" ] && mkdir "$bu_dir"
		
		cd "$repo_dir"
		file_list=$(get_repo_file_list)
		install_file_list "$file_list"
	;;
	uninstall)
		cd "$repo_dir"
		file_list=$(get_repo_file_list)
		uninstall_file_list "$file_list"
	;;
	prune)
		cd "$target_dir"
		file_list=`find . -type l -lname "$repo_dir*"`
		uninstall_file_list "$file_list"
	;;
	*)
		echo "This script manages symlinks in \$HOME to point to an identical"
		echo "filesystem layout in another directory (specified in the"
		echo "script's configuration). Useful for pointing dotfiles at a local"
		echo "Git dotfiles repo."
		echo
		echo "The path to the local copy of the dotfiles repo is set within"
		echo "script itself."
		echo
		echo "Only symlinks are removed on uninstall, so you can manually"
		echo "change a symlink to a normal file, thus removing it from"
		echo "the set of files that point to the repo, and it will be left"
		echo "alone on uninstall."
		echo
		echo "To change the repository location, uninstall/purge then"
		echo "reinstall."
		echo
		echo "Existing symlinks are NOT overwridden on install. This allows"
		echo "existing symlinks pointing to other repos with the same file"
		echo "heirarchy to coexist, with the first one taking precident. It"
		echo "also allows for manual overwriting of which dotfiles point to"
		echo "where."
		echo
		echo "Different sets of symlinks pointing to different repos can"
		echo "coexist."
		echo
		echo "All operations produce verbose output showing what file"
		echo "operations happened."
		echo
		echo "Usage: $0 [install | uninstall | prune]"
		echo
		echo "    install   : For every file in the repo, create a symlink to"
		echo "                it from the same relative path within \$HOME,"
		echo "                backing up any pre-existing file first. Doing"
		echo "                \"install\" multiple times (such as for updates)"
		echo "                is fine."
		echo
		echo "    uninstall : For every file in the repo, remove the symlink"
		echo "                with the same relative path in \$HOME, then"
		echo "                restore any existing backup file."
		echo "                    NOTE: This method only finds symlinks that"
		echo "                correspond to existing repo files. Symlinks for"
		echo "                repo files that have been removed or renamed"
		echo "                will not be found!"
		echo
		echo "    prune     : Traverses the entire \$HOME directory and finds"
		echo "                all symlinks pointing to the repo directory and"
		echo "                removes them, restoring from backup if a backup"
		echo "                exists. Potentially slow, depending on contents"
		echo "                of \$HOME."
	;;
esac

