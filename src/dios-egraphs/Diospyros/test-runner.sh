cd ..
case $1 in 
    run-opt)
        make run-opt test=$2
        ;;
    run-opt-stdout)
        make run-opt-stdout test=$2
        ;;
    no-opt-stdout)
        make no-opt-stdout test=$2
        ;;
    *)
        echo "match failure"
        ;;
esac
cd -