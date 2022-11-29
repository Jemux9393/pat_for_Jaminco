    


    for ean in $(< /root/Constant/Jaminco/list_of_books)
        do
            filename=${ean}.html
            curl -Ls https://www.decitre.fr/rechercher/result?q=$ean > $filename
            # A cause des apostrophes encodées...
            sed -i "s|&#039;|\'|g" $filename
            book_name=$(awk -F"\"" '/og:title/ { print $4}' $filename)
            check_soldout=$(grep 'En stock en ligne' $filename )
            if [[ -z $check_soldout ]]
                then    
                    echo "      name: \"$book_name\""
                    echo "      ean: \"$ean\""                    
                    echo "      disponiblity: \"Non disponible\""
                else
                    echo "      name: \"$book_name\""
                    echo "      ean: \"$ean\""                        
                    echo "      disponiblity: \"Disponible\""
            fi
            echo -e "\n###   ~~~ ###   ~~~  ###   ~~~ ###    "                  
    done