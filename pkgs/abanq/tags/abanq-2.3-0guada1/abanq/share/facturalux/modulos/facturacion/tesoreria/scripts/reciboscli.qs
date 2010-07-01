/***************************************************************************
                 reciboscli.qs  -  description
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
	function validateForm():Boolean { return this.ctx.interna_validateForm(); }
	function acceptedForm() { return this.ctx.interna_acceptedForm(); }
	function calculateField(fN:String):String { return this.ctx.interna_calculateField(fN); }
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
    var importeInicial:Number;
    function oficial( context ) { interna( context ); } 
	function bufferChanged(fN:String) {
		return this.ctx.oficial_bufferChanged(fN);
	}
	function cambiarEstado() {
		return this.ctx.oficial_cambiarEstado();
	}
	function obtenerEstado(idRecibo:String):String {
		return this.ctx.oficial_obtenerEstado(idRecibo);
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
	function pub_obtenerEstado(idRecibo:String):String {
		return this.obtenerEstado(idRecibo);
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
/** 
\D Se almacena el valor del importe inicial del recibo
\end
\C Los campos --fechav--, --importe--, --codcuenta-- y --coddir-- estarán deshabilitados.
\end
\end */
function interna_init()
{
	var cursor:FLSqlCursor = this.cursor();
	if (cursor.modeAccess() == cursor.Edit)
		this.iface.importeInicial = parseFloat(cursor.valueBuffer("importe"));
	connect(cursor, "bufferChanged(QString)", this, "iface.bufferChanged");
	connect(this.child("tdbPagosDevolCli").cursor(), "cursorUpdated()", this, "iface.cambiarEstado");
	if (cursor.modeAccess() == cursor.Edit)
		this.child("pushButtonAcceptContinue").close();
	this.child("fdbTexto").setValue(this.iface.calculateField("texto"));

	this.iface.bufferChanged("codcuenta");
	this.iface.cambiarEstado();
}


/** \C
El importe del recibo debe ser menor o igual del que tenía anteriormente. Si es menor el recibo se fraccionará.
La fecha de vencimiento debe ser siempre igual o posterior a la fecha de emisión del recibo.
\end */
function interna_validateForm():Boolean
{
	var util:FLUtil = new FLUtil();
	var cursor:FLSqlCursor = this.cursor();

	var importeActual:Number = parseFloat(cursor.valueBuffer("importe"));
	if (this.iface.importeInicial < importeActual) {
		MessageBox.warning(util.translate("scripts", "El importe del recibo debe ser menor o igual del que tenía anteriormente.\nSi es menor el recibo se fraccionará."), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
		this.child("fdbImporte").setFocus();
		return false;
	}

	if (util.daysTo(cursor.valueBuffer("fecha"), cursor.valueBuffer("fechav")) < 0) {
		MessageBox.warning(util.translate("scripts", "La fecha de vencimiento debe ser siempre igual o posterior\na la fecha de emisión del recibo."), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
		return false;
	}

	return true;
}

function interna_acceptedForm()
{
	var util:FLUtil = new FLUtil();
	/** \C
	Actualiza el riesgo del cliente, si existe
	\end */
	var codCliente:String = this.cursor().valueBuffer("codcliente");
	if (codCliente)
		flfactteso.iface.pub_actualizarRiesgoCliente(codCliente);

	/** \C
	Si el importe ha disminuido, genera un recibo complementario por la diferencia
	\end */
	var importeActual:Number = parseFloat(this.cursor().valueBuffer("importe"));
	if (importeActual < this.iface.importeInicial) {
		var cursor:FLSqlCursor = this.cursor();
		var numRecibo:Number = parseInt(util.sqlSelect("reciboscli", "numero", "idfactura = " + cursor.valueBuffer("idfactura") + " ORDER BY numero DESC")) + 1;
		var codFactura:String = util.sqlSelect("facturascli", "codigo", "idfactura = " + cursor.valueBuffer("idfactura"));
		var tasaConv:Number = parseFloat(util.sqlSelect("facturascli", "tasaconv", "idfactura = " + cursor.valueBuffer("idfactura")));

		var curRecibos:FLSqlCursor = new FLSqlCursor("reciboscli");
		var moneda:String = util.sqlSelect("divisas", "descripcion", "coddivisa = '" + cursor.valueBuffer("coddivisa") + "'");

		cursor.setValueBuffer("importeeuros", importeActual * tasaConv);
		
		curRecibos.setModeAccess(curRecibos.Insert);
		curRecibos.refreshBuffer();
		curRecibos.setValueBuffer("numero", numRecibo);
		curRecibos.setValueBuffer("idfactura", cursor.valueBuffer("idFactura"));
		curRecibos.setValueBuffer("importe", this.iface.importeInicial - importeActual);
		curRecibos.setValueBuffer("importeeuros", (this.iface.importeInicial - importeActual) * tasaConv);
		curRecibos.setValueBuffer("coddivisa", cursor.valueBuffer("coddivisa"));
		curRecibos.setValueBuffer("codigo", codFactura + "-" + flfacturac.iface.pub_cerosIzquierda(numRecibo, 2));
		curRecibos.setValueBuffer("codcliente", cursor.valueBuffer("codcliente"));
		curRecibos.setValueBuffer("nombrecliente", cursor.valueBuffer("nombrecliente"));
		curRecibos.setValueBuffer("cifnif", cursor.valueBuffer("cifnif"));
		var codDir:String = cursor.valueBuffer("coddir");
		if (codDir && codDir != "")
			curRecibos.setValueBuffer("coddir", cursor.valueBuffer("coddir"));
		curRecibos.setValueBuffer("direccion", cursor.valueBuffer("direccion"));
		curRecibos.setValueBuffer("codpostal", cursor.valueBuffer("codpostal"));
		curRecibos.setValueBuffer("ciudad", cursor.valueBuffer("ciudad"));
		curRecibos.setValueBuffer("provincia", cursor.valueBuffer("provincia"));
		curRecibos.setValueBuffer("codpais", cursor.valueBuffer("codpais"));
		curRecibos.setValueBuffer("fecha", cursor.valueBuffer("fecha"));
		curRecibos.setValueBuffer("fechav", cursor.valueBuffer("fechav"));
		curRecibos.setValueBuffer("codcuenta", cursor.valueBuffer("codcuenta"));
		curRecibos.setValueBuffer("descripcion", cursor.valueBuffer("descripcion"));
		curRecibos.setValueBuffer("ctaentidad", cursor.valueBuffer("ctaentidad"));
		curRecibos.setValueBuffer("ctaagencia", cursor.valueBuffer("ctaagencia"));
		curRecibos.setValueBuffer("dc", cursor.valueBuffer("dc"));
		curRecibos.setValueBuffer("cuenta", cursor.valueBuffer("cuenta"));
		curRecibos.setValueBuffer("estado", "Emitido");
		curRecibos.setValueBuffer("texto", util.enLetraMoneda(this.iface.importeInicial - importeActual, moneda));
		curRecibos.commitBuffer();
	}
}

function interna_calculateField(fN:String):String
{
	var util:FLUtil = new FLUtil();
	var cursor:FLSqlCursor = this.cursor();
	var valor:String;
	if (fN == "estado") {
		valor = this.iface.obtenerEstado(cursor.valueBuffer("idrecibo"));
	}

	if (fN == "texto") {
		var importe:Number = parseFloat(cursor.valueBuffer("importe"));
		var moneda:String = util.sqlSelect("divisas", "descripcion", "coddivisa = '" + cursor.valueBuffer("coddivisa") + "'");
		valor = util.enLetraMoneda(importe, moneda);
	}

	if (fN == "dc") {
		var entidad:String = cursor.valueBuffer("ctaentidad");
		var agencia:String = cursor.valueBuffer("ctaagencia");
		var cuenta:String = cursor.valueBuffer("cuenta");
		
		if (!entidad) entidad = "";
		if (!agencia) agencia = "";
		if (!cuenta) cuenta = "";
		
		if ( !entidad.isEmpty() && !agencia.isEmpty() && ! cuenta.isEmpty() && entidad.length == 4 && agencia.length == 4 && cuenta.length == 10 ) {
			var dc1:String = util.calcularDC(entidad + agencia);
			var dc2:String = util.calcularDC(cuenta);
			valor = dc1 + dc2;
		}
	}

	return valor;
}

//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
function oficial_bufferChanged(fN:String)
{
	/** \C
	El cambio del --importe-- bloquea pagos y devoluciones
	\end */
	if (fN == "importe") {
		this.child("fdbTexto").setValue(this.iface.calculateField("texto"));
		this.child("gbxPagDev").setDisabled(true);
	}

	/** \C
	El --dc-- de la cuenta bancaria se calcula automáticamente en base al resto de valores de la cuenta
	\end */
	if (fN == "codcuenta" || fN == "ctaentidad" || fN == "ctaagencia" || fN == "cuenta" )
			this.child("fdbDc").setValue(this.iface.calculateField("dc"));
}

/** \D
Cambia el valor del estado del recibo entre Emitido, Cobrado y Devuelto
\end */
function oficial_cambiarEstado()
{
	var util:FLUtil = new FLUtil;
	var cursor:FLSqlCursor = this.cursor();
	var estado:String = this.iface.calculateField("estado");
	this.child("fdbEstado").setValue(estado);
	if ( estado != "Emitido" )
		this.child("fdbImporte").setDisabled(true);
	else
		this.child("fdbImporte").setDisabled(false);
	
	if (util.sqlSelect("pagosdevolcli", "idremesa", "idrecibo = " + cursor.valueBuffer("idrecibo") + " ORDER BY fecha DESC, idpagodevol DESC") != 0) {
		this.child("lblRemesado").text = "REMESADO";
		this.child("fdbFechav").setDisabled(true);
		this.child("fdbImporte").setDisabled(true);
		this.child("fdbCodCuenta").setDisabled(true);
		this.child("coddir").setDisabled(true);
		this.child("tdbPagosDevolCli").setInsertOnly(true);
		this.child("pushButtonNext").close();
		this.child("pushButtonPrevious").close();
		this.child("pushButtonFirst").close();
		this.child("pushButtonLast").close();
	}
}

/** \D
Calcula el estado en función de los pagos y devoluciones asociados a un recibo
@param	idRecibo: Identificador del recibo cuyo estado se desea calcular
@return	Estado del recibo
\end */
function oficial_obtenerEstado(idRecibo:String):String
{
	var valor:String = "Emitido";
	var curPagosDevol:FLSqlCursor = new FLSqlCursor("pagosdevolcli");
	curPagosDevol.select("idrecibo = " + idRecibo + " ORDER BY fecha DESC, idpagodevol DESC");
	if (curPagosDevol.first()) {
		curPagosDevol.setModeAccess(curPagosDevol.Browse);
		curPagosDevol.refreshBuffer();
		if (curPagosDevol.valueBuffer("tipo") == "Pago")
			valor = "Pagado";
		else
			valor = "Devuelto";
	}
	return valor;
}

//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
