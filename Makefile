nothing: ; sudo apt-get update / sudo apt-get install nasm
	echo "salvar"	
salvar:
	git status
	git add .
	git commit -m "salvar cambios"
	git push