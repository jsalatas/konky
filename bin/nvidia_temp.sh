if ! nvidia-settings -query [gpu:0]/GPUCoreTemp -t > /dev/null ; then
    temp='N/A'
else 
    temp=`nvidia-settings -query [gpu:0]/GPUCoreTemp -t`
    temp="$temp°C"
fi
echo $temp
