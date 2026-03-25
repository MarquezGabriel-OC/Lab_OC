nothing: 
	echo "guardando"	
salvar:
	git status
	git add .
	git commit -m "salvar cambios"
	git push