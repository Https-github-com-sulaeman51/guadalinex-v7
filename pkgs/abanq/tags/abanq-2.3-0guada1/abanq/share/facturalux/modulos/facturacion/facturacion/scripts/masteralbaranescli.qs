/***************************************************************************
                 masteralbaranescli.qs  -  description
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
	function recordDelBeforealbaranescli() { return this.ctx.interna_recordDelBeforealbaranescli(); }
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
	/** \D @var pbnAAlbaran Botón de asociar a albarán \end */
	var pbnAAlbaran:Object;
	var pbnGFactura:Object;
	var tdbRecords:FLTableDB;
	var tbnImprimir:Object;
	var curFactura:FLSqlCursor;
	var curLineaFactura:FLSqlCursor;
	
    function oficial( context ) { interna( context ); } 
	function imprimir(codAlbaran:String) {
		return this.ctx.oficial_imprimir(codAlbaran);
	}
	function procesarEstado() {
		return this.ctx.oficial_procesarEstado();
	}
	function pbnGenerarFactura_clicked() {
		return this.ctx.oficial_pbnGenerarFactura_clicked();
	}
	function generarFactura(where:String, curAlbaran:FLSqlCursor):Number {
		return this.ctx.oficial_generarFactura(where, curAlbaran);
	}
	function copiaLineasAlbaran(idAlbaran:Number, idFactura:Number):Boolean {
		return this.ctx.oficial_copiaLineasAlbaran(idAlbaran, idFactura);
	}
	function commonCalculateField(fN:String, cursor:FLSqlCursor):String {
		return this.ctx.oficial_commonCalculateField(fN, cursor);
	}
	function restarCantidad(idLineaPedido:Number, cantidad:Number) {
		return this.ctx.oficial_restarCantidad(idLineaPedido, cantidad);
	}
	function asociarAAlbaran() {
		return this.ctx.oficial_asociarAAlbaran();
	}
	function whereAgrupacion(curAgrupar:FLSqlCursor):String {
		return this.ctx.oficial_whereAgrupacion(curAgrupar);
	}
	function copiaLineaAlbaran(curLineaAlbaran:FLSqlCursor, idFactura:Number):Number {
		return this.ctx.oficial_copiaLineaAlbaran(curLineaAlbaran, idFactura);
	}
	function totalesFactura():Boolean {
		return this.ctx.oficial_totalesFactura();
	}
	function datosFactura(curAlbaran:FLSqlCursor,where:String):Boolean {
		return this.ctx.oficial_datosFactura(curAlbaran,where);
	}
	function datosLineaFactura(curLineaAlbaran:FLSqlCursor):Boolean {
		return this.ctx.oficial_datosLineaFactura(curLineaAlbaran);
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
	function pub_whereAgrupacion(curAgrupar:FLSqlCursor):String {
		return this.whereAgrupacion(curAgrupar);
	}
	function pub_generarFactura(where:String, curAlbaran:FLSqlCursor):Number {
		return this.generarFactura(where, curAlbaran);
	}
	function pub_commonCalculateField(fN:String, cursor:FLSqlCursor):String {
		return this.commonCalculateField(fN, cursor);
	}
	function pub_restarCantidad(idLineaPedido:Number, cantidad:Number) {
		return this.restarCantidad(idLineaPedido, cantidad);
	}
	function pub_imprimir(codAlbaran:String) {
		return this.imprimir(codAlbaran);
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
/** \C
Este es el formulario maestro de albaranes a cliente.
\end */
function interna_init()
{
	this.iface.pbnAAlbaran = this.child("pbnAsociarAAlbaran");
	this.iface.pbnGFactura = this.child("pbnGenerarFactura");
	this.iface.tdbRecords = this.child("tableDBRecords");
	this.iface.tbnImprimir = this.child("toolButtonPrint");

	connect(this.iface.pbnAAlbaran, "clicked()", this, "iface.asociarAAlbaran");
	connect(this.iface.pbnGFactura, "clicked()", this, "iface.pbnGenerarFactura_clicked");
	connect(this.iface.tdbRecords, "currentChanged()", this, "iface.procesarEstado");
	connect(this.iface.tbnImprimir, "clicked()", this, "iface.imprimir");

	var codEjercicio:String = flfactppal.iface.pub_ejercicioActual();
	if (codEjercicio)
		this.cursor().setMainFilter("codejercicio='" + codEjercicio + "'");

	this.iface.procesarEstado();
}

/** \C
Al borrar un albarán se recalcularán los valores del campo total en albarán del pedido asociado, así como el estado del pedido (si lo hay)
\end */
function interna_recordDelBeforealbaranescli()
{
		var cursor:FLSqlCursor = this.cursor();
		var cantidad:Number;
		var idLineaPedido:Number;
		var numeroPedido:Number;

		var query:FLSqlQuery = new FLSqlQuery();
		query.setTablesList("lineasalbaranescli");
		query.setSelect("idlineapedido, cantidad");
		query.setFrom("lineasalbaranescli");
		query.setWhere("idalbaran = " + cursor.valueBuffer("idalbaran") + " AND idlineapedido <> 0;");
		query.exec();

		while (query.next()) {
				idLineaPedido = query.value(0);
				cantidad = query.value(1);
				this.iface.restarCantidad(idLineaPedido, cantidad);
		}

		var qryPedido:FLSqlQuery = new FLSqlQuery();
		qryPedido.setTablesList("lineasalbaranescli");
		qryPedido.setSelect("idpedido");
		qryPedido.setFrom("lineasalbaranescli");
		qryPedido.setWhere("idalbaran = " + cursor.valueBuffer("idalbaran") + " AND idpedido <> 0 GROUP BY idpedido;");
		qryPedido.exec();
		while (qryPedido.next()) {
				idPedido = qryPedido.value(0);
				formRecordlineasalbaranescli.iface.pub_actualizarEstadoPedido(idPedido,cursor);
		}
}

//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
/** \C
Al pulsar el botón imprimir se lanzará el informe correspondiente al albarán seleccionado (en caso de que el módulo de informes esté cargado)
\end */
function oficial_imprimir(codAlbaran:String)
{
	if (sys.isLoadedModule("flfactinfo")) {
		var codigo:String;
		if (codAlbaran) {
			codigo = codAlbaran;
		} else {
			if (!this.cursor().isValid())
				return;
			codigo = this.cursor().valueBuffer("codigo");
		}
		var curImprimir:FLSqlCursor = new FLSqlCursor("i_albaranescli");
		curImprimir.setModeAccess(curImprimir.Insert);
		curImprimir.refreshBuffer();
		curImprimir.setValueBuffer("descripcion", "temp");
		curImprimir.setValueBuffer("d_albaranescli_codigo", codigo);
		curImprimir.setValueBuffer("h_albaranescli_codigo", codigo);
		flfactinfo.iface.pub_lanzarInforme(curImprimir, "i_albaranescli");
	} else
		flfactppal.iface.pub_msgNoDisponible("Informes");
}

function oficial_procesarEstado()
{
		if (this.cursor().valueBuffer("ptefactura") == true)
				this.iface.pbnGFactura.setDisabled(false);
		else
				this.iface.pbnGFactura.setDisabled(true);
}

/** \C
Al pulsar el botón de generar factura se creará la factura correspondiente al albarán.
\end */
function oficial_pbnGenerarFactura_clicked()
{
	var util:FLUtil = new FLUtil;
	var cursor:FLSqlCursor = this.cursor();
	var where:String = "idalbaran = " + cursor.valueBuffer("idalbaran");

	if (cursor.valueBuffer("ptefactura") == false) {
		MessageBox.warning(util.translate("scripts", "Ya existe la factura correspondiente a este albarán"), MessageBox.Ok, MessageBox.NoButton);
		this.iface.procesarEstado();
		return;
	}
	this.iface.pbnGFactura.setEnabled(false);

	cursor.transaction(false);
	try {
		if (this.iface.generarFactura(where, cursor))
			cursor.commit();
		else
			cursor.rollback();
	}
	catch (e) {
		cursor.rollback();
		MessageBox.critical(util.translate("scripts", "Hubo un error en la generación de la factura:") + "\n" + e, MessageBox.Ok, MessageBox.NoButton);
	}
	
	this.iface.tdbRecords.refresh();
	this.iface.procesarEstado();
}

/** \D
Genera la factura asociada a uno o más albaranes
@param where: Sentencia where para la consulta de búsqueda de los albaranes a agrupar
@param curAlbaran: Cursor con los datos principales que se copiarán del albarán a la factura
@return True: Copia realizada con éxito, False: Error
\end */
function oficial_generarFactura(where:String, curAlbaran:FLSqlCursor):Number
{
	if (!this.iface.curFactura)
		this.iface.curFactura = new FLSqlCursor("facturascli");
	
	this.iface.curFactura.setModeAccess(this.iface.curFactura.Insert);
	this.iface.curFactura.refreshBuffer();
	
	if (!this.iface.datosFactura(curAlbaran,where))
		return false;
	
	if (!this.iface.curFactura.commitBuffer()) {
		return false;
	}
	
	var idFactura:Number = this.iface.curFactura.valueBuffer("idfactura");
	
	var curAlbaranes:FLSqlCursor = new FLSqlCursor("albaranescli");
	curAlbaranes.select(where);
	var idAlbaran:Number;
	while (curAlbaranes.next()) {
		curAlbaranes.setModeAccess(curAlbaranes.Edit);
		curAlbaranes.refreshBuffer();
		idAlbaran = curAlbaranes.valueBuffer("idalbaran");
		if (!this.iface.copiaLineasAlbaran(idAlbaran, idFactura)) {
			return false;
		}
		curAlbaranes.setValueBuffer("idfactura", idFactura);
		curAlbaranes.setValueBuffer("ptefactura", false);
		if (!curAlbaranes.commitBuffer()) {
			return false;
		}
	}

	this.iface.curFactura.select("idfactura = " + idFactura);
	if (this.iface.curFactura.first()) {
/*
		if (!formRecordfacturascli.iface.pub_actualizarLineasIva(idFactura))
			return false;
*/
			
		this.iface.curFactura.setModeAccess(this.iface.curFactura.Edit);
		this.iface.curFactura.refreshBuffer();
		
		if (!this.iface.totalesFactura())
			return false;
		
		if (this.iface.curFactura.commitBuffer() == false)
			return false;
	}
	return idFactura;
}

/** \D Informa los datos de una factura a partir de los de uno o varios albaranes
@param	curAlbaran: Cursor que contiene los datos a incluir en la factura
@return	True si el cálculo se realiza correctamente, false en caso contrario
\end */
function oficial_datosFactura(curAlbaran:FLSqlCursor,where:String):Boolean
{
	var util:FLUtil = new FLUtil();
	var fecha:String;
	if (curAlbaran.action() == "albaranescli") {
		var hoy:Date = new Date();
		fecha = hoy.toString();
	} else
		fecha = curAlbaran.valueBuffer("fecha");
		
	var codEjercicio:String = curAlbaran.valueBuffer("codejercicio");
	var datosDoc:Array = flfacturac.iface.pub_datosDocFacturacion(fecha, codEjercicio, "facturascli");
	if (!datosDoc.ok)
		return false;
	if (datosDoc.modificaciones == true) {
		codEjercicio = datosDoc.codEjercicio;
		fecha = datosDoc.fecha;
	}
	
	var codDir:Number = util.sqlSelect("dirclientes", "id", "codcliente = '" + curAlbaran.valueBuffer("codcliente") + "' AND domfacturacion = 'true'");
	with (this.iface.curFactura) {
		setValueBuffer("codserie", curAlbaran.valueBuffer("codserie"));
		setValueBuffer("codejercicio", codEjercicio);
		setValueBuffer("irpf", curAlbaran.valueBuffer("irpf"));
		setValueBuffer("fecha", fecha);
		setValueBuffer("codagente", curAlbaran.valueBuffer("codagente"));
		setValueBuffer("porcomision", curAlbaran.valueBuffer("porcomision"));
		setValueBuffer("codalmacen", curAlbaran.valueBuffer("codalmacen"));
		setValueBuffer("codpago", curAlbaran.valueBuffer("codpago"));
		setValueBuffer("coddivisa", curAlbaran.valueBuffer("coddivisa"));
		setValueBuffer("tasaconv", curAlbaran.valueBuffer("tasaconv"));
		setValueBuffer("codcliente", curAlbaran.valueBuffer("codcliente"));
		setValueBuffer("cifnif", curAlbaran.valueBuffer("cifnif"));
		setValueBuffer("nombrecliente", curAlbaran.valueBuffer("nombrecliente"));
		if (!codDir) {
			codDir = curAlbaran.valueBuffer("coddir")
			if (codDir == 0) {
				this.setNull("coddir");
			} else 
				setValueBuffer("coddir", curAlbaran.valueBuffer("coddir"));
			setValueBuffer("direccion", curAlbaran.valueBuffer("direccion"));
			setValueBuffer("codpostal", curAlbaran.valueBuffer("codpostal"));
			setValueBuffer("ciudad", curAlbaran.valueBuffer("ciudad"));
			setValueBuffer("provincia", curAlbaran.valueBuffer("provincia"));
			setValueBuffer("apartado", curAlbaran.valueBuffer("apartado"));
			setValueBuffer("codpais", curAlbaran.valueBuffer("codpais"));
		} else {
			setValueBuffer("coddir", codDir);
			setValueBuffer("direccion", util.sqlSelect("dirclientes","direccion","id = " + codDir));
			setValueBuffer("codpostal", util.sqlSelect("dirclientes","codpostal","id = " + codDir));
			setValueBuffer("ciudad", util.sqlSelect("dirclientes","ciudad","id = " + codDir));
			setValueBuffer("provincia", util.sqlSelect("dirclientes","provincia","id = " + codDir));
			setValueBuffer("apartado", util.sqlSelect("dirclientes","apartado","id = " + codDir));
			setValueBuffer("codpais", util.sqlSelect("dirclientes","codpais","id = " + codDir));
		}
		setValueBuffer("observaciones", curAlbaran.valueBuffer("observaciones"));
		setValueBuffer("recfinanciero", curAlbaran.valueBuffer("recfinanciero"));
		setValueBuffer("automatica", true);
	}
	return true;
}

/** \D Copia los datos de una línea de albarán en una línea de factura
@param	curLineaAlbaran: Cursor que contiene los datos a incluir en la línea de factura
@return	True si la copia se realiza correctamente, false en caso contrario
\end */
function oficial_datosLineaFactura(curLineaAlbaran:FLSqlCursor):Boolean
{
	with (this.iface.curLineaFactura) {
		setValueBuffer("referencia", curLineaAlbaran.valueBuffer("referencia"));
		setValueBuffer("descripcion", curLineaAlbaran.valueBuffer("descripcion"));
		setValueBuffer("pvpunitario", curLineaAlbaran.valueBuffer("pvpunitario"));
		setValueBuffer("pvpsindto", curLineaAlbaran.valueBuffer("pvpsindto"));
		setValueBuffer("cantidad", curLineaAlbaran.valueBuffer("cantidad"));
		setValueBuffer("pvptotal", curLineaAlbaran.valueBuffer("pvptotal"));
		setValueBuffer("codimpuesto", curLineaAlbaran.valueBuffer("codimpuesto"));
		setValueBuffer("iva", curLineaAlbaran.valueBuffer("iva"));
		setValueBuffer("recargo", curLineaAlbaran.valueBuffer("recargo"));
		setValueBuffer("dtolineal", curLineaAlbaran.valueBuffer("dtolineal"));
		setValueBuffer("dtopor", curLineaAlbaran.valueBuffer("dtopor"));
		setValueBuffer("idalbaran", curLineaAlbaran.valueBuffer("idalbaran"));
	}
	return true;
}

/** \D Informa los datos de una factura referentes a totales (I.V.A., neto, etc.)
@return	True si el cálculo se realiza correctamente, false en caso contrario
\end */
function oficial_totalesFactura():Boolean
{
	with (this.iface.curFactura) {
		setValueBuffer("neto", formfacturascli.iface.pub_commonCalculateField("neto", this));
		setValueBuffer("totaliva", formfacturascli.iface.pub_commonCalculateField("totaliva", this));
		setValueBuffer("totalirpf", formfacturascli.iface.pub_commonCalculateField("totalirpf", this));
		setValueBuffer("totalrecargo", formfacturascli.iface.pub_commonCalculateField("totalrecargo", this));
		setValueBuffer("total", formfacturascli.iface.pub_commonCalculateField("total", this));
		setValueBuffer("totaleuros", formfacturascli.iface.pub_commonCalculateField("totaleuros", this));
	}
	return true;
}

/** \D
Copia las líneas de un albarán como líneas de su factura asociada
@param idAlbaran: Identificador del albarán
@param idFactura: Identificador de la factura
@return	Verdadero si no hay error, falso en caso contrario
\end */
function oficial_copiaLineasAlbaran(idAlbaran:Number, idFactura:Number):Boolean
{
	var curLineaAlbaran:FLSqlCursor = new FLSqlCursor("lineasalbaranescli");
	curLineaAlbaran.select("idalbaran = " + idAlbaran);
	
	while (curLineaAlbaran.next()) {
		curLineaAlbaran.setModeAccess(curLineaAlbaran.Browse);
		if (!this.iface.copiaLineaAlbaran(curLineaAlbaran, idFactura))
			return false;
	}
	return true;
}

/** \D
Copia una línea de albarán en su factura asociada
@param curLineaAlbaran: Cursor posicionado en la línea de albarán a copiar
@param idFactura: Identificador de la factura
@return	Identificador de la línea de factura si no hay error, falso en caso contrario
\end */
function oficial_copiaLineaAlbaran(curLineaAlbaran:FLSqlCursor, idFactura:Number):Number
{
	if (!this.iface.curLineaFactura)
		this.iface.curLineaFactura = new FLSqlCursor("lineasfacturascli");
	
	with (this.iface.curLineaFactura) {
		setModeAccess(Insert);
		refreshBuffer();
		setValueBuffer("idfactura", idFactura);
	}
	
	if (!this.iface.datosLineaFactura(curLineaAlbaran))
		return false;
		
	if (!this.iface.curLineaFactura.commitBuffer())
			return false;
	
	return this.iface.curLineaFactura.valueBuffer("idlinea");
}

function oficial_commonCalculateField(fN:String, cursor:FLSqlCursor):String
{
	var util:FLUtil = new FLUtil();
	var valor:String;

	/** \C
	El --código-- se construye como la concatenación de --codserie--, --codejercicio-- y --numero--
	\end */
	if (fN == "codigo")
			valor = flfacturac.iface.pub_construirCodigo(cursor.valueBuffer("codserie"), cursor.valueBuffer("codejercicio"), cursor.valueBuffer("numero"));

	switch (fN) {
		/** \C
		El --total-- es el --neto-- menos el --totalirpf-- más el --totaliva-- más el --totalrecargo-- más el --recfinanciero--
		\end */
		case "total": {
			var neto:Number = parseFloat(cursor.valueBuffer("neto"));
			var totalIrpf:Number = parseFloat(cursor.valueBuffer("totalirpf"));
			var totalIva:Number = parseFloat(cursor.valueBuffer("totaliva"));
			var totalRecargo:Number = parseFloat(cursor.valueBuffer("totalrecargo"));
			var recFinanciero:Number = (parseFloat(cursor.valueBuffer("recfinanciero")) * neto) / 100;
			recFinanciero = parseFloat(util.roundFieldValue(recFinanciero, "albaranescli", "total"));
			valor = neto - totalIrpf + totalIva + totalRecargo + recFinanciero;
			valor = parseFloat(util.roundFieldValue(valor, "albaranescli", "total"));
			break;
		}
		case "lblComision": {
			valor = (parseFloat(cursor.valueBuffer("porcomision")) * (parseFloat(cursor.valueBuffer("neto")))) / 100;
			valor = parseFloat(util.roundFieldValue(valor, "albaranescli", "total"));
			break;
		}
		case "lblRecFinanciero": {
			valor = (parseFloat(cursor.valueBuffer("recfinanciero")) * (parseFloat(cursor.valueBuffer("neto")))) / 100;
			valor = parseFloat(util.roundFieldValue(valor, "albaranescli", "total"));
			break;
		}
		/** \C
		El --totaleuros-- es el producto del --total-- por la --tasaconv--
		\end */
		case "totaleuros": {
			var total:Number = parseFloat(cursor.valueBuffer("total"));
			var tasaConv:Number = parseFloat(cursor.valueBuffer("tasaconv"));
			valor = total * tasaConv;
			valor = parseFloat(util.roundFieldValue(valor, "albaranescli", "totaleuros"));
			break;
		}
		/** \C
		El --neto-- es la suma del pvp total de las líneas de albarán
		\end */
		case "neto": {
			valor = util.sqlSelect("lineasalbaranescli", "SUM(pvptotal)", "idalbaran = " + cursor.valueBuffer("idalbaran"));
			valor = parseFloat(util.roundFieldValue(valor, "albaranescli", "neto"));
			break;
		}
		/** \C
		El --totaliva-- es la suma del iva correspondiente a las líneas de albarán
		\end */
		case "totaliva": {
			var codCli:String = cursor.valueBuffer("codcliente");
			var regIva:String = util.sqlSelect("clientes","regimeniva","codcliente = '" + codCli + "'");
			if(regIva == "U.E." || regIva == "Exento"){
				valor = 0;
				break;
			}
			valor = util.sqlSelect("lineasalbaranescli", "SUM((pvptotal * iva) / 100)", "idalbaran = " + cursor.valueBuffer("idalbaran"));
			valor = parseFloat(util.roundFieldValue(valor, "albaranescli", "totaliva"));
			break;
		}
		/** \C
		El --totarecargo-- es la suma del recargo correspondiente a las líneas de albarán
		\end */
		case "totalrecargo": {
			var codCli:String = cursor.valueBuffer("codcliente");
			var regIva:String = util.sqlSelect("clientes","regimeniva","codcliente = '" + codCli + "'");
			if(regIva == "U.E." || regIva == "Exento"){
				valor = 0;
				break;
			}
			valor = util.sqlSelect("lineasalbaranescli", "SUM((pvptotal * recargo) / 100)", "idalbaran = " + cursor.valueBuffer("idalbaran"));
			valor = parseFloat(util.roundFieldValue(valor, "albaranescli", "totalrecargo"));
			break;
		}
		/** \C
		El --coddir-- corresponde a la dirección del cliente marcada como dirección de facturación
		\end */
		case "coddir": {
			valor = util.sqlSelect("dirclientes", "id", "codcliente = '" + cursor.valueBuffer("codcliente") + "' AND domenvio = 'true'");
			break;
		}
		/** \C
		El --irpf-- es el asociado a la --codserie-- del albarán
		\end */
		case "irpf": {
			valor = util.sqlSelect("series", "irpf", "codserie = '" + cursor.valueBuffer("codserie") + "'");
			break;
		}
		/** \C
		El --totalirpf-- es el producto del --irpf-- por el --neto--
		\end */
		case "totalirpf": {
			valor = (parseFloat(cursor.valueBuffer("irpf")) * (parseFloat(cursor.valueBuffer("neto")))) / 100;
			valor = parseFloat(util.roundFieldValue(valor, "albaranescli", "totalirpf"));
			break;
		}
		case "provincia": {
			valor = util.sqlSelect("dirclientes", "provincia", "id = " + cursor.valueBuffer("coddir"));
			if (!valor)
				valor = cursor.valueBuffer("provincia");
			break;
		}
		case "codpais": {
			valor = util.sqlSelect("dirclientes", "codpais", "id = " + cursor.valueBuffer("coddir"));
			if (!valor)
				valor = cursor.valueBuffer("codpais");
			break;
		}
	}
	return valor;
}


/** \D
Cambia el valor del campo totalenalbarán de una determinada línea de pedido
@param idLineaPedido: Identificador de la línea de pedido
@param cantidad: Cantidad a restar
\end */
function oficial_restarCantidad(idLineaPedido:Number, cantidad:Number)
{
		var curLineaPedido:FLSqlCursor = new FLSqlCursor("lineaspedidoscli");
		curLineaPedido.select("idlinea = " + idLineaPedido);
		if (curLineaPedido.first()) {
				curLineaPedido.setModeAccess(curLineaPedido.Edit);
				curLineaPedido.refreshBuffer();
				curLineaPedido.setValueBuffer("totalenalbaran", parseFloat(curLineaPedido.valueBuffer("totalenalbaran")) - parseFloat(cantidad));
				curLineaPedido.commitBuffer();
		}
}

/** \C
Al pulsar el botón de asociar a albarán se abre la ventana de agrupar pedidos de cliente
\end */
function oficial_asociarAAlbaran()
{
		var util:FLUtil = new FLUtil;
		var f:Object = new FLFormSearchDB("agruparpedidoscli");
		var cursor:FLSqlCursor = f.cursor();
		var where:String;
		var codCliente:String;
		var codAlmacen:String;

		cursor.setActivatedCheckIntegrity(false);
		cursor.select();
		if (!cursor.first())
				cursor.setModeAccess(cursor.Insert);
		else
				cursor.setModeAccess(cursor.Edit);

		f.setMainWidget();
		cursor.refreshBuffer();
		var acpt:String = f.exec("codejercicio");

		if (acpt) {
				cursor.commitBuffer();
				var curAgruparPedidos:FLSqlCursor = new FLSqlCursor("agruparpedidoscli");
				curAgruparPedidos.select();
				if (curAgruparPedidos.first()) {
						where = this.iface.whereAgrupacion(curAgruparPedidos);
						var excepciones = curAgruparPedidos.valueBuffer("excepciones");
						if (!excepciones.isEmpty())
								where += " AND idpedido NOT IN (" + excepciones + ")";

						var qryAgruparPedidos = new FLSqlQuery;
						qryAgruparPedidos.setTablesList("pedidoscli");
						qryAgruparPedidos.setSelect("codcliente,codalmacen");
						qryAgruparPedidos.setFrom("pedidoscli");
						qryAgruparPedidos.setWhere(where + " GROUP BY codcliente,codalmacen");
						if (!qryAgruparPedidos.exec())
								return;
								
						var totalClientes:Number = qryAgruparPedidos.size();
						util.createProgressDialog(util.translate("scripts", "Generando albaranes"), totalClientes);
						util.setProgress(1);
						var j:Number = 0; 
						
						var curPedido :FLSqlCursor= new FLSqlCursor("pedidoscli");
						var whereAlbaran:String;
						while (qryAgruparPedidos.next()) {
								codCliente = qryAgruparPedidos.value(0);
								codAlmacen = qryAgruparPedidos.value(1);
								whereAlbaran = where + " AND codcliente = '" + codCliente + "'" + " AND codalmacen = '" + codAlmacen + "'";
								curPedido.transaction(false);
								curPedido.select(whereAlbaran);
								if (!curPedido.first()) {
										curPedido.rollback();
										util.destroyProgressDialog();
										return;
								}
								curPedido.setValueBuffer("fecha", curAgruparPedidos.valueBuffer("fecha"));
								if (formpedidoscli.iface.pub_generarAlbaran(whereAlbaran, curPedido)) {
										curPedido.commit();
								} else {
										curPedido.rollback();
										util.destroyProgressDialog();
										return;
								}
								util.setProgress(++j);
						}
						util.setProgress(totalClientes);
						util.destroyProgressDialog();
				}
				f.close();
				this.iface.tdbRecords.refresh();
		}
}

/** \D
Construye la sentencia WHERE de la consulta que buscará los pedidos a agrupar
@param curAgrupar: Cursor de la tabla agruparpedidoscli que contiene los valores de los criterios de búsqueda
@return Sentencia where
\end */
function oficial_whereAgrupacion(curAgrupar:FLSqlCursor):String
{
		var codCliente:String = curAgrupar.valueBuffer("codcliente");
		var nombreCliente:String = curAgrupar.valueBuffer("nombrecliente");
		var cifNif:String = curAgrupar.valueBuffer("cifnif");
		var codAlmacen:String = curAgrupar.valueBuffer("codalmacen");
		var codPago:String = curAgrupar.valueBuffer("codpago");
		var codDivisa:String = curAgrupar.valueBuffer("coddivisa");
		var codSerie:String = curAgrupar.valueBuffer("codserie");
		var codEjercicio:String = curAgrupar.valueBuffer("codejercicio");
		var fechaDesde:String = curAgrupar.valueBuffer("fechadesde");
		var fechaHasta:String = curAgrupar.valueBuffer("fechahasta");
		var where:String = "servido <> 'Sí'";
		if (codCliente && !codCliente.isEmpty())
				where += " AND codcliente = '" + codCliente + "'";
		if (cifNif && !cifNif.isEmpty())
				where += " AND cifnif = '" + cifNif + "'";
		if (codAlmacen && !codAlmacen.isEmpty())
				where = where + " AND codalmacen = '" + codAlmacen + "'";
		where = where + " AND fecha >= '" + fechaDesde + "'";
		where = where + " AND fecha <= '" + fechaHasta + "'";
		if (codPago && !codPago.isEmpty() != "")
				where = where + " AND codpago = '" + codPago + "'";
		if (codDivisa && !codDivisa.isEmpty())
				where = where + " AND coddivisa = '" + codDivisa + "'";
		if (codSerie && !codSerie.isEmpty())
				where = where + " AND codserie = '" + codSerie + "'";
		if (codEjercicio && !codEjercicio.isEmpty())
				where = where + " AND codejercicio = '" + codEjercicio + "'";
		return where;
}

//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
