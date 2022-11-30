## VARIABLES ##

reference_file="/home/ralph/git_repos/pat_for_Jaminco/list_of_books"
result_yml_file="/home/ralph/git_repos/pat_for_Jaminco/result.yaml"
playbook_file="/home/ralph/git_repos/pat_for_Jaminco/ansible/main.yml"

function display_tunning ()  {

    book_sum=$(wc -l < $reference_file )

}

function collect_data () {
    rm $result_yml_file
    echo "1 - Lancement de la collecte des données..."
    echo $book_sum "livres à rechercher"
    book_counter="1"
    for ean in $(< $reference_file)
        do
            echo "Collecte livre" $book_counter "/" $book_sum
            filename=${ean}.html
            curl -Ls https://www.decitre.fr/rechercher/result?q=$ean > $filename
            decode_encoded_char
            book_name=$(awk -F"\"" '/og:title/ { print $4}' $filename)
            check_soldout=$(grep 'En stock en ligne' $filename )
            if [[ -z $check_soldout ]]
                then
                    if [[ "$counter" -lt 1 ]]; then counter=$((counter+1)); echo "livres:" >> $result_yml_file; fi                
                    echo "  $ean:" >> $result_yml_file                      
                    echo "    name: \"$book_name\"" >> $result_yml_file
                    echo "    ean: \"$ean\"" >> $result_yml_file              
                    echo "    disponiblity: \"Non disponible\"" >> $result_yml_file
                else
                    if [[ "$counter" -lt 1 ]]; then counter=$((counter+1)); echo "livres:" >> $result_yml_file; fi                
                    echo "  $ean:" >> $result_yml_file  
                    echo "    name: \"$book_name\"" >> $result_yml_file
                    echo "    ean: \"$ean\"" >> $result_yml_file                        
                    echo "    disponiblity: \"Disponible\"" >> $result_yml_file
            fi
            book_counter=$((book_counter+1))             
    done
    echo "Collecte des données terminé..."
}

function format_data () {

    echo "2 - Mise à jour du site avec les nouvelles données..."
    ansible-playbook $playbook_file


}


function decode_encoded_char () {

    # Remplacement apostrophe
    sed -i "s|&#039;|\'|g" $filename

}

display_tunning
collect_data
format_data

echo "Le site est à jour ! http://blackplatform.ovh/jaminco.html "