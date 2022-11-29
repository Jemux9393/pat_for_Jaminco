    


    for ean in $(< /root/Constant/Jaminco/list_of_books)
        do
            filename=${ean}.html
            curl -Ls https://www.decitre.fr/rechercher/result?q=$ean > $filename
            decode_encoded_char
            book_name=$(awk -F"\"" '/og:title/ { print $4}' $filename)
            check_soldout=$(grep 'En stock en ligne' $filename )
            if [[ -z $check_soldout ]]
                then
                    if [[ "$counter" -lt 1 ]]; then counter=$((counter+1)); echo "livres:" >> result.yaml; fi                
                    echo "  $ean:" >> result.yaml                      
                    echo "    name: \"$book_name\"" >> result.yaml
                    echo "    ean: \"$ean\"" >> result.yaml>> result.yaml              
                    echo "    disponiblity: \"Non disponible\"" >> result.yaml
                else
                    if [[ "$counter" -lt 1 ]]; then counter=$((counter+1)); echo "livres:" >> result.yaml; fi                
                    echo "  $ean:" >> result.yaml  
                    echo "    name: \"$book_name\"" >> result.yaml
                    echo "    ean: \"$ean\"" >> result.yaml                        
                    echo "    disponiblity: \"Disponible\"" >> result.yaml
            fi             
    done

function decode_encoded_char () {

    # Remplacement apostrophe
    sed -i "s|&#039;|\'|g" $filename

}