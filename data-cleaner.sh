#!/bin/bash

base_dir="/path/to/data"
data_files="sample"

IFS=','
for split_filenames in ${data_files}; do
  data_file=$( echo "${split_filenames}" )
  unset IFS
  if [ "$( ls -A ${base_dir}/${data_file}.csv )" ]; then
    if [[ -f "${base_dir}/${data_file}_clean.csv" ]]; then
      rm -f "${base_dir}/${data_file}_clean.csv" && touch "${base_dir}/${data_file}_clean.csv"
    else
      touch "${base_dir}/${data_file}_clean.csv"
    fi
    while read line; do
      ip_addr=$( echo "${line}" | cut -d"[" -f2 | cut -d"]" -f1 )
      if [[ ${ip_addr} == *", '"[0-9]*"."* ]]; then
        count=0
        for i in ${ip_addr}; do
          i=$( echo $i | sed "s/'//g" | sed "s/[[:blank:]]//g" | sed "s/,//g" )
          if [ ! "$tmp_array" ]; then
            #declare -a ${tmp_array} >/dev/null 2>&1
            tmp_array=("$i")
            count=$(($count + 1))
          else
            tmp_array=("${tmp_array[@]}" "$i")
            count=$(($count + 1))
          fi
        done
        host_type=$( echo "${line}" | cut -d"," -f1 )
        hostname=$( echo "${line}" | cut -d"," -f2 )
        val=$((${#tmp_array[@]} + 3)) && device_location=$( echo "${line}" | cut -d"," -f"${val}" )
        val=$((${#tmp_array[@]} + 4)) && domain=$( echo "${line}" | cut -d"," -f"${val}" )
        val=$((${#tmp_array[@]} + 5)) && dns_domain=$( echo "${line}" | cut -d"," -f"${val}" )
        mac_address=$( echo "${line}" | cut -d"\"" -f4 | cut -d"\"" -f1 )
        os=$( echo "${line}" | cut -d"\"" -f5 | cut -d"," -f2 )
        os_version=$( echo "${line}" | cut -d"\"" -f5 | cut -d"," -f3 )
        vendor=$( echo "${line}" | cut -d"\"" -f5 | cut -d"," -f4 )
        model=$( echo "${line}" | cut -d"\"" -f5 | cut -d"," -f5 )
        serial=$( echo "${line}" | cut -d"\"" -f5 | cut -d"," -f6 )
        for (( x=0; x < $count; x++ )); do
          echo "$host_type,$hostname,${tmp_array[$x]},$device_location,$domain,$dns_domain,\"$mac_address\",$os,$os_version,$vendor,$model,$serial" >> "${base_dir}/${data_file}_clean.csv"
        done
      else
        echo ${line} >> "${base_dir}/${data_file}_clean.csv"
      fi
      unset tmp_array
    done < "${base_dir}/${data_file}.csv"
  fi
done
