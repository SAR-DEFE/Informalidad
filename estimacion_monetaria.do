/*
Título: estimación_monetaria.do
Detalle: do file empleado para estimar la economía informal de Honduras 2001-2021
		 usando el método de demanda del circulante.
*/

clear all

/*

Definir ubicaciones de la computadora:
global path: establece la dirección dónde se encuentran los datos
global out: establece la dirección dónde se guardarán los resultados

*/
 
 if "`c(username)'" == "jbermudez" {
	 global path "C:\Users\jbermudez\OneDrive - SAR\Informalidad"
	 global out  "C:\Users\jbermudez\OneDrive - SAR\Notas técnicas y papers\Economía informal\out informalidad"
 }
 else if "`c(username)'" == "Owner" {
	 global path "C:\Users\Owner\OneDrive - SAR\Informalidad"
	 global out  "C:\Users\Owner\OneDrive - SAR\Notas técnicas y papers\Economía informal\out informalidad"
 }
 else if "`c(username)'" == "jcabrera" { 										// <- Usuario de Bayardo
	 global path ""
	 global out  ""
 }
 else if "`c(username)'" == "" {												// <- Usuario de Francisco
	 global path ""
	 global out  ""
 }
 
 
 * Importar base de datos crudos y preparar variables antes de la estimación
 
 import excel using "$path\BDD_informalidad.xlsx", firstrow clear sheet("2001-2021")
 
 tsset year, yearly
 
 gen bm_m3  = log(1 + (billetes_monedas / m3))
 
 replace población = población / 1000000
 gen pib_pc = log(1 + (pib_nominal / población))
 
 gen trib = log(1 + (ingresos_tributarios / pib_nominal))
 
 gen remu = log(1 + (remuneraciones / pib_nominal))
 
 gen tir = log(1 + (tasa_real / 100))
 
 gen dum08 = cond(year == 2008, 1, 0)
 gen dum09 = cond(year == 2009, 1, 0)
 
 eststo: prais bm_m3 trib dum08 dum09, vce(robust) ssesearch 
 eststo: prais bm_m3 trib pib_pc dum08 dum09, vce(robust) ssesearch 
 eststo: prais bm_m3 trib pib_pc remu dum08 dum09, vce(robust) ssesearch 
 eststo: prais bm_m3 trib pib_pc remu tir dum08 dum09, vce(robust) ssesearch 
 
 
 
 
 
 
 
 
 
 