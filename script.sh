function display_tunning ()  {

    book_sum=$(wc -l < list_of_books)


}

function collect_data () {
    rm result.yaml
    echo "1 - Lancement de la collecte des données..."
    echo $book_sum "livres à rechercher"
    book_counter="1"
    for ean in $(< list_of_books)
        do
            echo "Collecte livre" $book_counter "/" $book_sum
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
            book_counter=$((book_counter+1))             
    done
    echo "Collecte des données terminé..."
}

function format_data () {

    echo "2 - Mise à jour du site avec les nouvelles données..."
    ansible-playbook ansible/main.yml


}


function decode_encoded_char () {

    # Remplacement apostrophe
    sed -i "s|&#039;|\'|g" $filename

}

display_tunning
collect_data
format_data

echo "Le site est à jour ! http://blackplatform.ovh/jaminco.html "