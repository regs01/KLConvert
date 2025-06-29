#!/bin/bash
# Retriving a short list of dependency packages based on linked libraries
# MIT
# coth
# https://github.com/regs01

if [ $# -ne 1 ]; then
    echo "Usage: $0 /path/to/executable"
    exit 1
fi

EXECUTABLE="$1"

# review: argument?
# note: ubuntu using different servers for ports complicating it
arch=$(dpkg --print-architecture)

# in_array (string $value, array[] $array): (int)bool
function in_array()
{

  (( $# != 2 )) && exit_message 127

  local value="$1"
  local -n array="$2"
  [[ ${#array[@]} -lt 1 ]] && return 0

  for item in "${array[@]}"
  do
    [[ "$item" == "$value" ]] && return 1
  done

  return 0

}  

# remove_from_array (string $value, array[] $array): int
function remove_from_array()
{

  (( $# != 2 )) && exit_message 127

  local value="$1"
  local -n array="$2"
  local new_array=()
  local result=0
  local index=0;

  for item in "${array[@]}"
  do
    index+=1
    [[ "$item" == "$value" ]] && result+=1
    [[ "$item" != "$value" ]] && new_array+=("$item")
  done

  array=("${new_array[@]}")

  return $result  

}

# get_lib_list (string $filname): string
function get_lib_list()
{

  (( $# != 1 )) && exit_message 127

  local elf_file="$1"
  local ldd_output=$(ldd "$elf_file" 2> /dev/null)
  echo "$ldd_output"

}

# function get_package (string $filname): string
function get_package()
{

  (( $# != 1 )) && exit_message 127

  local lib="$1"
  local lib_filename=$(basename "$lib")
  local package
  package=$(dpkg -S "$lib_filename" | grep ":$arch" | awk -F: '{print $1}' | sort -u 2> /dev/null | head -n 1)
  echo "$package"

}

# function get_depends (string $package, *array[] $array)
function get_depends() 
{

  (( $# != 2 )) && exit_message 127

  local pkg="$1"
  local -n all_depends="$2"
  local new_depends

  echo "    Processing $pkg..."
  new_depends=$(LC_ALL=C apt-cache depends "$pkg:$arch" 2>/dev/null | grep -E '^\s*Depends:' | awk '{print $2}' | grep -v '[<>|]')

  for dep in $new_depends
  do
    in_array "$dep" all_depends
    (( $? == 1 )) && continue
    all_depends+=("$dep")
    get_depends "$dep" $2
  done

}

# exit_message (int $code, string $message);
function exit_message()
{

  message=""
  parent_function=${FUNCNAME[1]}
  [[ $parent_function == 'exit_message' ]] && parent_function=${FUNCNAME[2]}
  (( $# < 1 || $# > 2 )) &&  exit 1
  (( $# == 2 )) && message=$2
  
  code=$1
  if ! [[ "$code" =~ ^[0-9]+$ ]]
  then  
    # todo: preserve original error message or orriginal function
    # idea: check if ${FUNCNAME[1]} is exit_message, then ${FUNCNAME[2]}?
    exit_message 127
  fi

  if [[ "$#" -eq 1 && -z $message ]]
  then
    case "$code" in
      127) message="No or wrong arguments in function $parent_function()"
           ;;
    esac
  fi

  [[ ! -z $message ]] && echo $message 
  exit $code

} 

declare -a depends_list
declare -a depends_short_list
declare -a depends_full_list

echo "Input executable: '$EXECUTABLE'."

ldd_output=$(get_lib_list "$EXECUTABLE")
if [ -z "$ldd_output" ]; then
  echo "No dependencies found."
  exit 1
fi

echo
echo "Building package list..."

OLDIFS=$IFS
IFS=$'\n'
for line in $ldd_output
do
  lib=$(echo "$line" | grep "=>" | awk '{print $3}')
  if [ -n "$lib" ]; then
    printf "  Getting package for $lib... "
    package=$(get_package "$lib")
    printf "$package"
    if [ -n "$package" ]
    then
      in_array "$package" depends_list
      (( $? == 0 )) && depends_list+=("$package") 
    fi
    printf "\n"
  fi
done
IFS=$OLDIFS

depends_short_list=("${depends_list[@]}")

echo
echo "Building comprehensive dependency list..."

for package in ${depends_list[@]}
do
    echo "  Getting recursive dependencies for package: $package"
    get_depends "$package" depends_full_list
    (( ${#depends_full_list[@]} == 0 )) && continue

    for dep in ${depends_full_list[@]}
    do
      in_array "$dep" depends_list
      (( $? == 1  )) && remove_from_array "$dep" depends_short_list
    done

done

echo
echo "Original dependency list: ${depends_list[*]}"
echo
echo "Contracted depency list: ${depends_short_list[*]}"