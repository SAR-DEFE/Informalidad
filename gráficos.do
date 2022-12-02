* DO file para elaborar gráficos con las estimaciones de informalidad

 clear all

/*
Definir ubicaciones de la computadora:
global path: establece la dirección dónde se encuentran los datos
global out: establece la dirección dónde se guardarán los resultados
*/
 
 if "`c(username)'" == "jbermudez" {
	 global path "C:\Users\jbermudez\OneDrive - SAR\Informalidad"
	 global out  "C:\Users\jbermudez\OneDrive - SAR\Notas técnicas y papers\Economía informal\out informalidad"
	 global graphop "legend(region(lcolor(none))) graphr(color(white))"
 }
 else if "`c(username)'" == "Owner" {
	 global path "C:\Users\Owner\OneDrive - SAR\Informalidad"
	 global out  "C:\Users\Owner\OneDrive - SAR\Notas técnicas y papers\Economía informal\out informalidad"
	 global graphop "legend(region(lcolor(none))) graphr(color(white))"
 }
 else if "`c(username)'" == "jcabrera" { 										// <- Usuario de Bayardo
	 global path ""
	 global out  ""
	 global graphop "legend(region(lcolor(none))) graphr(color(white))"
 }
 else if "`c(username)'" == "" {												// <- Usuario de Francisco
	 global path ""
	 global out  ""
	 global graphop "legend(region(lcolor(none))) graphr(color(white))"
 }
 
 import delimited using "$path\base_eval_inf.csv", clear
 tsset fecha, yearly
 
 format egd %4.1fc
 format monet %4.1fc
 twoway (scatter egd fecha, mcolor(blue%60) mlabel(egd) mlabposition(12) mlabsize(vsmall) mlabcolor(blue%60)) (line egd fecha, lc(blue%60)) /// 
        (scatter monet fecha, mcolor(red%60)  mlabel(monet) mlabposition(12) mlabsize(vsmall) mlabcolor(red%60)) (line monet fecha, lc(red%60)), ///
        $graphop legend(order(1 "Estimación DGE" 3 "Estimación Circulante")) xtitle("Año") ytitle("% del PIB") xscale(titlegap(3)) yscale(titlegap(3)) ///
        ylabel(40(2)50 40 "40%" 42 "42%" 44 "44%" 46 "46%" 48 "48%" 50 "50%")
 graph export "$out\estimaciones_propias.pdf", replace
 
 
 