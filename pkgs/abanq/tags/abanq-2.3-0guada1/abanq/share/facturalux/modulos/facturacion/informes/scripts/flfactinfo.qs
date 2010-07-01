/***************************************************************************
                 flfactinfo.qs  -  description
                             -------------------
    begin                : lun abr 26 2004
    copyright            : (C) 2004 by InfoSiAL S.L.
    email                : mail@infosial.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

/** @file */

/** @class_declaration interna */
////////////////////////////////////////////////////////////////////////////
//// DECLARACION ///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//// INTERNA /////////////////////////////////////////////////////
class interna {
    var ctx:Object;
    function interna( context ) { this.ctx = context; }
    function init() { this.ctx.interna_init(); }
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
	var variosIvas_:Boolean;
	var acumulados:Array = []; // Acumulados de valores numéricos en el informe
	var cuentaAcum:Array = []; // Almacena cuántos valores se han acumulado en cada índice del array acumulados
    function oficial( context ) { interna( context ); }
	function datosPieFactura(nodo:FLDomNode, campo:String):Number {
		return this.ctx.oficial_datosPieFactura(nodo, campo);
	}
	function crearInforme(nombreInforme:String) {
		return this.ctx.oficial_crearInforme(nombreInforme);
	}
	function lanzarInforme(cursor:FLSqlCursor, nombreInforme:String, orderBy:String, groupBy:String, etiquetas:Boolean, impDirecta:Boolean, whereFijo:String, nombreReport:String, numCopias:Number, impresora:String) {
		return this.ctx.oficial_lanzarInforme(cursor, nombreInforme, orderBy, groupBy, etiquetas, impDirecta, whereFijo, nombreReport, numCopias, impresora);
	}
	function seleccionEtiquetaInicial():Array {
		return this.ctx.oficial_seleccionEtiquetaInicial();
	}
	function establecerConsulta(cursor:FLSqlCursor, nombreConsulta:String, orderBy:String, groupBy:String, whereFijo:String):FLSqlQuery {
		return this.ctx.oficial_establecerConsulta(cursor, nombreConsulta, orderBy, groupBy, whereFijo);
	}
	function obtenerSigno(s:String):String {
		return this.ctx.oficial_obtenerSigno(s);
	}
	function fieldName(s:String):String {
		return this.ctx.oficial_fieldName(s);
	}
	function obtenerAcumulado(nodo:FLDomNode, campo:String):String {
		return this.ctx.oficial_obtenerAcumulado(nodo,campo);
	}
	function acumularValor(nodo:FLDomNode, campo:String):String {
		return this.ctx.oficial_acumularValor(nodo, campo);
	}
	function restaurarAcumulado(nodo:FLDomNode, campo:String):String {
		return this.ctx.oficial_restaurarAcumulado(nodo, campo);
	}
	function logo(nodo:FLDomNode, campo:String):String {
		return this.ctx.oficial_logo(nodo, campo);
	}
	function porIVA(nodo:FLDomNode, campo:String):String {
		return this.ctx.oficial_porIVA(nodo, campo);
	}
	function desgloseIva(nodo:FLDomNode, campo:String):String {
		return this.ctx.oficial_desgloseIva(nodo, campo);
	}
	function desgloseBaseImponible(nodo:FLDomNode, campo:String):String {
		return this.ctx.oficial_desgloseBaseImponible(nodo, campo);
	}
	function desgloseRecargo(nodo:FLDomNode, campo:String):String {
		return this.ctx.oficial_desgloseRecargo(nodo, campo);
	}
	function desgloseTotal(nodo:FLDomNode, campo:String):String {
		return this.ctx.oficial_desgloseTotal(nodo, campo);
	}

}
//// OFICIAL /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////
class head extends oficial {
    function head( context ) { oficial ( context ); }
}
//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_declaration ifaceCtx */
/////////////////////////////////////////////////////////////////
//// INTERFACE  /////////////////////////////////////////////////
class ifaceCtx extends head {
	function ifaceCtx( context ) { head( context ); }
	function pub_lanzarInforme(cursor:FLSqlCursor, nombreInforme:String, orderBy:String, groupBy:String, etiquetas:Boolean, impDirecta:Boolean, whereFijo:String, nombreReport:String, numCopias:Number, impresora:String) {
	return this.lanzarInforme(cursor, nombreInforme, orderBy, groupBy, etiquetas, impDirecta, whereFijo, nombreReport, numCopias, impresora);
	}
	function pub_datosPieFactura(nodo:FLDomNode, campo:String):Number {
		return this.datosPieFactura(nodo, campo);
	}
	function pub_logo(nodo:FLDomNode, campo:String):String {
		return this.logo(nodo, campo);
	}
	function pub_porIVA(nodo:FLDomNode, campo:String):String {
		return this.porIVA(nodo, campo);
	}
	function pub_desgloseIva(nodo:FLDomNode, campo:String):String {
		return this.desgloseIva(nodo, campo);
	}
	function pub_desgloseBaseImponible(nodo:FLDomNode, campo:String):String {
		return this.desgloseBaseImponible(nodo, campo);
	}
	function pub_desgloseRecargo(nodo:FLDomNode, campo:String):String {
		return this.desgloseRecargo(nodo, campo);
	}
	function pub_desgloseTotal(nodo:FLDomNode, campo:String):String {
		return this.desgloseTotal(nodo, campo);
	}
}
const iface = new ifaceCtx( this );
//// INTERFACE  /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition interna */
////////////////////////////////////////////////////////////////////////////
//// DEFINICION ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//// INTERNA /////////////////////////////////////////////////////
function interna_init() {
	var util:FLUtil = new FLUtil;
	util.writeSettingEntry("kugar/banner", "");
}
//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
/** \D
Obtiene los datos de totalización de pie de factura
@param	nodo: Nodo XML con los datos de la línea que se va a mostrar en el informe
@param	campo: Campo a mostrar
@return	Valor del campo
\end */
function oficial_datosPieFactura(nodo:FLDomNode, campo:String):Number
{
		var util:FLUtil = new FLUtil();
		var sCampo:String = campo.toString();
		var tablaFacturas:String;
		var tablaIva:String;
		if (sCampo.charAt(0) == "P"
				&& sCampo.charAt(1) == "_") {
				tablaFacturas = "facturasprov";
				tablaIva = "lineasivafactprov";
				campo = "";
				for (var i:Number = 2; i < sCampo.length; i++)
						campo += sCampo.charAt(i);
		} else {
				tablaFacturas = "facturascli";
				tablaIva = "lineasivafactcli";
		}

		var idFactura:Number = nodo.attributeValue(tablaFacturas + ".idfactura");
		var util:FLUtil = new FLUtil;
		var res:Number;
		if (campo == "BI4") {
				res = util.sqlSelect(tablaIva, "neto", "idfactura = " + idFactura + " AND iva = 4");
		} else if (campo == "BI7") {
				res = util.sqlSelect(tablaIva, "neto", "idfactura = " + idFactura + " AND iva = 7");
		} else if (campo == "BI16") {
				res = util.sqlSelect(tablaIva, "neto", "idfactura = " + idFactura + " AND iva = 16");
		} else if (campo == "IVA4") {
				res = util.sqlSelect(tablaIva, "totaliva", "idfactura = " + idFactura + " AND iva = 4");
		} else if (campo == "IVA7") {
				res = util.sqlSelect(tablaIva, "totaliva", "idfactura = " + idFactura + " AND iva = 7");
		} else if (campo == "IVA16") {
				res = util.sqlSelect(tablaIva, "totaliva", "idfactura = " + idFactura + " AND iva = 16");
		} else if (campo == "POR_RE4") {
				res = util.sqlSelect(tablaIva, "recargo", "idfactura = " + idFactura + " AND iva = 4");
				if (res && parseFloat(res) != 0)
						res += "%";
		} else if (campo == "POR_RE7") {
				res = util.sqlSelect(tablaIva, "recargo", "idfactura = " + idFactura + " AND iva = 7");
				if (res && parseFloat(res) != 0)
						res += "%";
		} else if (campo == "POR_RE16") {
				res = util.sqlSelect(tablaIva, "recargo", "idfactura = " + idFactura + " AND iva = 16");
				if (res && parseFloat(res) != 0)
						res += "%";
		} else if (campo == "RE4") {
				res = util.sqlSelect(tablaIva, "totalrecargo", "idfactura = " + idFactura + " AND iva = 4");
				if (parseFloat(res) != 0)
						res = util.buildNumber(res, "f", 2);
		} else if (campo == "RE7") {
				res = util.sqlSelect(tablaIva, "totalrecargo", "idfactura = " + idFactura + " AND iva = 7");
				if (parseFloat(res) != 0)
						res = util.buildNumber(res, "f", 2);
		} else if (campo == "RE16") {
				res = util.sqlSelect(tablaIva, "totalrecargo", "idfactura = " + idFactura + " AND iva = 16");
				if (parseFloat(res) != 0)
						res = util.buildNumber(res, "f", 2);
		} else if (campo == "T4") {
				res = util.sqlSelect(tablaIva, "totallinea", "idfactura = " + idFactura + " AND iva = 4");
		} else if (campo == "T7") {
				res = util.sqlSelect(tablaIva, "totallinea", "idfactura = " + idFactura + " AND iva = 7");
		} else if (campo == "T16") {
				res = util.sqlSelect(tablaIva, "totallinea", "idfactura = " + idFactura + " AND iva = 16");
		}
		if (parseFloat(res) == 0 || !res)
				res = "";
		return res;
}

/** \D
Crea el informe especificado
@param	nombreinforme: Nombre del informe a crear
\end */
function oficial_crearInforme(nombreInforme:String)
{
		if (this.iface.establecerCriteriosBusqueda(nombreInforme) == true);
			this.iface.lanzarInforme(nombreInforme);
}

/** \D Establece la fila y columna de la primera etiqueta a imprimir para los informes de etiquetas
\end */
function oficial_seleccionEtiquetaInicial():Array
{
	var etiquetaInicial:Array = [];
	etiquetaInicial["fila"] = 0;
	etiquetaInicial["col"] = 0;
	var util:FLUtil = new FLUtil;
	var dialog:Object = new Dialog;
	dialog.caption = util.translate("scripts","Elegir fila y columna a imprimir");
	dialog.okButtonText = util.translate("scripts","Aceptar");
	dialog.cancelButtonText = util.translate("scripts","Cancelar");

	var text:Object = new Label;
	text.text = util.translate("scripts","Ha seleccionado un informe de etiquetas,\nelija la fila y la columna a imprimir:");
	dialog.add(text);

	var spbNumColum:Object= new SpinBox;
	spbNumColum.label = util.translate("scripts","Columnas");
	spbNumColum.minimum = 1;
	spbNumColum.maximum = 30;
	dialog.add(spbNumColum);

	var spbNumFila:Object = new SpinBox;
	spbNumFila.label = util.translate("scripts","Filas");
	spbNumFila.minimum = 1;
	spbNumFila.maximum = 30;
	dialog.add(spbNumFila);

	if (dialog.exec()){
		etiquetaInicial["fila"] = spbNumFila.value;
		etiquetaInicial["col"] = spbNumColum.value;
	}
	return etiquetaInicial;
}

/** \D Establece la consulta del informe, creando el where a partir de los campos del cursor
@param	cursor: Cursor posicionado en un registro de criterios de búsqueda
@param	nombreConsulta: Nombre del fichero con la descripción de la consulta
@param	orderBy: Cláusula Order By
@param	groupBy: Cláusula Group By
@param	whereFijo: Cláusula Where que se añade al construido a partir de los campos del cursor
@return	consulta o false si hay error
\end */
function oficial_establecerConsulta(cursor:FLSqlCursor, nombreConsulta:String, orderBy:String, groupBy:String, whereFijo:String):FLSqlQuery
{
	var util:FLUtil = new FLUtil();
	var q:FLSqlQuery = new FLSqlQuery(nombreConsulta);
	var fieldList:String = util.nombreCampos(cursor.table());
	var cuenta:Number = parseFloat(fieldList[0]);

	var signo:String;
	var fN:String;
	var valor:String;
	var primerCriterio:Boolean = false;
	var where:String = "";
	for (var i:Number = 1; i <= cuenta; i++) {
		if (cursor.isNull(fieldList[i]))
			continue;
		signo = this.iface.obtenerSigno(fieldList[i]);
		if (signo != "") {
			fN = this.iface.fieldName(fieldList[i]);
			valor = cursor.valueBuffer(fieldList[i]);
			if (valor == "Sí")
				valor = 1;
			if (valor == "No")
				valor = 0;
			if (valor == "Todos")
				valor = "";
			if (!valor.toString().isEmpty()) {
				if (primerCriterio == true)
					where += "AND ";
				where += fN + " " + signo + " '" + valor + "' ";
				primerCriterio = true;
			}
		}
	}
	if (whereFijo && whereFijo != "") {
		if (where == "")
			where = whereFijo;
		else
			where = whereFijo + " AND (" + where + ")";
	}
		
	if (groupBy && groupBy != "") {
		if (where == "")
			where = "1 = 1";
		where += " GROUP BY " + groupBy;
	}
	q.setWhere(where);
	
	if (orderBy)
		q.setOrderBy(orderBy);
	
	return q;
}
/** \D
Lanza un informe
@param	cursor: Cursor con los criterios de búsqueda para la consulta base del informe
@param	nombreinforme: Nombre del informe
@param	orderBy: Cláusula ORDER BY de la consulta base
@param	groupBy: Cláusula GROUP BY de la consulta base
@param	etiquetas: Indicador de si se trata de un informe de etiquetas
@param	impDirecta: Indicador para imprimir directaemnte el informe, sin previsualización
@param	whereFijo: Sentencia where que debe preceder a la sentencia where calculada por la función
\end */
function oficial_lanzarInforme(cursor:FLSqlCursor, nombreInforme:String, orderBy:String, groupBy:String, etiquetas:Boolean, impDirecta:Boolean, whereFijo:String, nombreReport:String, numCopias:Number, impresora:String)
{
	var util:FLUtil = new FLUtil();
	var etiquetaInicial:Array = [];
	if (etiquetas == true) {
		etiquetaInicial = this.iface.seleccionEtiquetaInicial();
	} else {
		etiquetaInicial["fila"] = 0;
		etiquetaInicial["col"] = 0;
	}

	var q:FLSqlQuery = this.iface.establecerConsulta(cursor, nombreInforme, orderBy, groupBy, whereFijo);
debug("------ CONSULTA -------" + q.sql());
	if (q.exec() == false) {
		MessageBox.critical(util.translate("scripts", "Falló la consulta"), MessageBox.Ok, MessageBox.NoButton);
		return;
	} else {
		if (q.first() == false) {
			MessageBox.warning(util.translate("scripts", "No hay registros que cumplan los criterios de búsqueda establecidos"), MessageBox.Ok, MessageBox.NoButton);
			return;
		}
	}

	if (!nombreReport) 
		nombreReport = nombreInforme;
			
	var rptViewer:FLReportViewer = new FLReportViewer();
	rptViewer.setReportTemplate(nombreReport);
	rptViewer.setReportData(q);
	rptViewer.renderReport(etiquetaInicial.fila, etiquetaInicial.col);
	if (numCopias)
		rptViewer.setNumCopies(numCopias);
	if (impresora) {
		try {
			rptViewer.setPrinterName(impresora);
		}
		catch (e) {}
	}
		
	if (impDirecta)
		rptViewer.printReport();
	else
		rptViewer.exec();
}

/** \D
Obtiene el operador lógico a aplicar en la cláusula where de la consulta a partir de los primeros caracteres del parámetro
@param	s: Nombre del campo que contiene un criterio de búsqueda
@return	Operador lógico a aplicar
\end */
function oficial_obtenerSigno(s:String):String
{
		if (s.toString().charAt(1) == "_") {
				switch(s.toString().charAt(0)) {
						case "d": {
								return ">=";
						}
						case "h": {
								return "<=";
						}
						case "i": {
								return "=";
						}
				}
		}
		return  "";
}

/** \D
Obtiene el nombre del campo de la cadena s desde su segunda posición. Sustituye '_' por '.', dos '_" seguidos indica que realmente es '_"
@param	s: Nombre del campo que contiene un criterio de búsqueda
@return	Nombre procesado
\end */
function oficial_fieldName(s:String):String
{
		var fN:String = "";
		var c:String;
		for (var i:Number = 2; (s.toString().charAt(i)); i++) {
				c = s.toString().charAt(i);
				if (c == "_")
						if (s.toString().charAt(i + 1) == "_") {
								fN += "_";
								i++;
						} else
								fN += "."
				else
						fN += s.toString().charAt(i);
		}
		return fN;
}

/** \D Devuelve el valor del acumulado para el la variable indicada
@param	campo: Identificador del acumulado a devolver
*/
function oficial_obtenerAcumulado(nodo:FLDomNode, campo:String):String 
{
	return this.iface.acumulados[campo];
}

/** \D Acumula el valor del registro actual del informe
@param	campo: String con dos valores separados por '/':
	1. Identificador del acumulado a devolver
	2. Nombre del campo de la consulta del informe cuyo valor hay que acumular
*/
function oficial_acumularValor(nodo:FLDomNode, campo:String):String
{
	var campos:Array = campo.split("/");
	var valor:Number = parseFloat(campos[1]);
	if (isNaN(valor))
		valor = parseFloat(nodo.attributeValue(campos[1]));
	
	if (!this.iface.acumulados[campos[0]]) {
		this.iface.acumulados[campos[0]] = valor;
		this.iface.cuentaAcum[campos[0]] = 1;
	} else {
		this.iface.acumulados[campos[0]] += valor;
		this.iface.cuentaAcum[campos[0]]++;
	}
	return "0";
}

/** \D Restaura la variable del acumulado
@param	campo: Identificador del acumulado a restaurar
*/
function oficial_restaurarAcumulado(nodo:FLDomNode, campo:String):String
{
	this.iface.acumulados[campo] = 0;
	this.iface.cuentaAcum[campo] = 0;
	
	return "0";
}

/** \D
Obtiene el xpm del logo de la empresa
@return xpm del logo
*/
function oficial_logo(nodo:FLDomNode, campo:String):String
{
	var util:FLUtil = new FLUtil;
	return util.sqlSelect("empresa", "logo", "1 = 1");
}

function oficial_porIVA(nodo:FLDomNode, campo:String):String
{
	var util:FLUtil = new FLUtil;
	var idDocumento:String;
	var tablaPadre:String;
	var tabla:String;
	var campoClave:String;
	var porIva:String;
	switch (campo) {
		case "facturacli": {
			tablaPadre = "facturascli";
			tabla = "lineasfacturascli";
			campoClave = "idfactura";
			break;
		}
		case "facturaprov": {
			tablaPadre = "facturasprov";
			tabla = "lineasfacturasprov";
			campoClave = "idfactura";
			break;
		}
	}
	idDocumento = nodo.attributeValue(tablaPadre + "." + campoClave);
	this.iface.variosIvas_ = false;
	porIva = util.sqlSelect(tabla, "iva", campoClave + " = " + idDocumento);
	if (!porIva)
		porIva = 0;

	if (util.sqlSelect(tabla, "iva", campoClave + " = " + idDocumento + " AND iva <> " + porIva)) {
		this.iface.variosIvas_ = true;
		porIva = "";
	} else {
		porIva += "%";
	}
	
	return "I.V.A. " + porIva;
}


function oficial_desgloseIva(nodo:FLDomNode, campo:String):String
{
	if (!this.iface.variosIvas_)
		return "";
	
	var util:FLUtil = new FLUtil;
	var idDocumento:String;
	var tabla:String;
	var campoClave:String;
	switch (campo) {
		case "facturacli": {
			tablaPadre = "facturascli";
			tabla = "lineasivafactcli";
			campoClave = "idfactura";
			break;
		}
		case "facturaprov": {
			tablaPadre = "facturasprov";
			tabla = "lineasivafactprov";
			campoClave = "idfactura";
			break;
		}
	}
	idDocumento = nodo.attributeValue(tablaPadre + "." + campoClave);
	
	var qryIvas:FLSqlQuery = new FLSqlQuery();
	with (qryIvas) {
		setTablesList(tabla);
		setSelect("totaliva");
		setFrom(tabla);
		setWhere(campoClave + " = " + idDocumento + " ORDER BY iva");
	}
	if (!qryIvas.exec())
		return false;
	var listaIvas:String = "";
	while (qryIvas.next()) {
		if (listaIvas != "")
			listaIvas += "\n";
		listaIvas += util.roundFieldValue(qryIvas.value("totaliva"), tabla, "totaliva");
	}
	return listaIvas;
}

function oficial_desgloseBaseImponible(nodo:FLDomNode, campo:String):String
{
	if (!this.iface.variosIvas_)
		return "";
	
	var util:FLUtil = new FLUtil;
	var idDocumento:String;
	var tabla:String;
	var campoClave:String;
	switch (campo) {
		case "facturacli": {
			tablaPadre = "facturascli";
			tabla = "lineasivafactcli";
			campoClave = "idfactura";
			break;
		}
		case "facturaprov": {
			tablaPadre = "facturasprov";
			tabla = "lineasivafactprov";
			campoClave = "idfactura";
			break;
		}
	}
	idDocumento = nodo.attributeValue(tablaPadre + "." + campoClave);
	
	var qryIvas:FLSqlQuery = new FLSqlQuery();
	with (qryIvas) {
		setTablesList(tabla);
		setSelect("iva, neto");
		setFrom(tabla);
		setWhere(campoClave + " = " + idDocumento + " ORDER BY iva");
	}
	if (!qryIvas.exec())
		return false;
	var listaBases:String = "";
	while (qryIvas.next()) {
		if (listaBases != "")
			listaBases += "\n";
		listaBases += "I.V.A. " + qryIvas.value("iva") + "%: " + util.roundFieldValue(qryIvas.value("neto"), tabla, "neto");
	}
	return listaBases;
}

function oficial_desgloseRecargo(nodo:FLDomNode, campo:String):String
{
	if (!this.iface.variosIvas_)
		return "";
	
	var util:FLUtil = new FLUtil;
	var idDocumento:String;
	var tabla:String;
	var campoClave:String;
	switch (campo) {
		case "facturacli": {
			tablaPadre = "facturascli";
			tabla = "lineasivafactcli";
			campoClave = "idfactura";
			break;
		}
		case "facturaprov": {
			tablaPadre = "facturasprov";
			tabla = "lineasivafactprov";
			campoClave = "idfactura";
			break;
		}
	}
	idDocumento = nodo.attributeValue(tablaPadre + "." + campoClave);
	
	var qryIvas:FLSqlQuery = new FLSqlQuery();
	with (qryIvas) {
		setTablesList(tabla);
		setSelect("totalrecargo");
		setFrom(tabla);
		setWhere(campoClave + " = " + idDocumento + " ORDER BY iva");
	}
	if (!qryIvas.exec())
		return false;
	var listaRecargo:String = "";
	while (qryIvas.next()) {
		if (listaRecargo != "")
			listaRecargo += "\n";
		if (qryIvas.value("totalrecargo") == 0)
			listaRecargo += " ";
		else
			listaRecargo += util.roundFieldValue(qryIvas.value("totalrecargo"), tabla, "totalrecargo");
	}
	return listaRecargo;
}


function oficial_desgloseTotal(nodo:FLDomNode, campo:String):String
{
	if (!this.iface.variosIvas_)
		return "";
	
	var util:FLUtil = new FLUtil;
	var idDocumento:String;
	var tabla:String;
	var campoClave:String;
	switch (campo) {
		case "facturacli": {
			tablaPadre = "facturascli";
			tabla = "lineasivafactcli";
			campoClave = "idfactura";
			break;
		}
		case "facturaprov": {
			tablaPadre = "facturasprov";
			tabla = "lineasivafactprov";
			campoClave = "idfactura";
			break;
		}
	}
	idDocumento = nodo.attributeValue(tablaPadre + "." + campoClave);
	
	var qryIvas:FLSqlQuery = new FLSqlQuery();
	with (qryIvas) {
		setTablesList(tabla);
		setSelect("totallinea");
		setFrom(tabla);
		setWhere(campoClave + " = " + idDocumento + " ORDER BY iva");
	}
	if (!qryIvas.exec())
		return false;
	var listaTotal:String = "";
	while (qryIvas.next()) {
		if (listaTotal != "")
			listaTotal += "\n";
		listaTotal += util.roundFieldValue(qryIvas.value("totallinea"), tabla, "totallinea");
	}
	return listaTotal;
}

//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
