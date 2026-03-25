nothing: 
	echo "salvar"	
salvar:
	git status
	git add .
	git commit -m "salvar cambios"
	git push