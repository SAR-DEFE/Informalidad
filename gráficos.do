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
	 global path "C:\Users\Owner\Desktop\Informalidad"
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
 
 format egd monet wb_egd wb_mimic schneider %4.1fc
 
 * Gráficos
 twoway (scatter egd fecha, mcolor(blue%60) mlabel(egd) mlabposition(12) mlabsize(vsmall) mlabcolor(blue%60)) (line egd fecha, lc(blue%60)), ///
        $graphop legend(order(1 "Estimación DGE")) xtitle("Año") ytitle("% del PIB") xscale(titlegap(3)) yscale(titlegap(3)) ///
        ylabel(40(2)50 40 "40%" 42 "42%" 44 "44%" 46 "46%" 48 "48%" 50 "50%")
 graph export "$out\estimaciones_propias1.pdf", replace
 
 twoway (scatter egd fecha, mcolor(blue%60) mlabel(egd) mlabposition(12) mlabsize(vsmall) mlabcolor(blue%60)) (line egd fecha, lc(blue%60)) /// 
        (scatter monet fecha, mcolor(red%60)  mlabel(monet) mlabposition(12) mlabsize(vsmall) mlabcolor(red%60)) (line monet fecha, lc(red%60)), ///
        $graphop legend(order(1 "Estimación DGE" 3 "Estimación Circulante")) xtitle("Año") ytitle("% del PIB") xscale(titlegap(3)) yscale(titlegap(3)) ///
        ylabel(40(2)50 40 "40%" 42 "42%" 44 "44%" 46 "46%" 48 "48%" 50 "50%")
 graph export "$out\estimaciones_propias.pdf", replace
 
 twoway (connected egd fecha, 	mcolor(blue%60) msize(small) mlabcolor(blue%60) lc(blue%60)) /// 
        (connected monet fecha, mcolor(red%60) msize(small) mlabcolor(red%60) lc(red%60)) ///
		(line wb_egd fecha,     lc(green)) ///
		(line wb_mimic fecha,   lc(cyan)) ///
		(line schneider fecha,  lc(gold)), ///
        $graphop legend(row(2) order(1 "DGE" 2 "Circulante" 3 "WB EGD" 4 "BW MIMIC" 5 "Schneider (2018)")) xtitle("Año") ytitle("% del PIB") xscale(titlegap(3)) yscale(titlegap(3)) ///
        ylabel(36(4)52 36 "36%" 40 "40%" 44 "44%" 48 "48%" 52 "52%")
 graph export "$out\estimaciones_comparativas.pdf", replace
 
 global var "egd monet wb_egd wb_mimic schneider"
 
 
 
 
 
 