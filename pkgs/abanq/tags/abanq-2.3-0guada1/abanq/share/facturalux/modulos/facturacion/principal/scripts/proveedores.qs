/***************************************************************************
                 proveedores.qs  -  description
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
	function calculateCounter():String { return this.ctx.interna_calculateCounter(); }
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
	var ejercicioActual:String;
	var longSubcuenta:Number;
	var bloqueoSubcuenta:Boolean;
	var posActualPuntoSubcuenta:Number;
	var toolButtonInsertSub:Object;
	var toolButtonDelSub:Object;
	var toolButtonInsertContacto:Object;
	var toolButtonDeleteContacto:Object;
	var toolButtonDeleteContactoProveedor:Object;
	var toolButtonInsertContactoProveedor:Object;
	var toolButtonBuscarContacto:Object;
	
	function oficial( context ) { interna( context ); } 
	function cambiarDireccion() { return this.ctx.oficial_cambiarDireccion(); }
	function cargarDireccion() { return this.ctx.oficial_cargarDireccion(); }
	function bufferChanged(fN:String) { return this.ctx.oficial_bufferChanged(fN); }
	function calculateField(fN:String) {
		return this.ctx.oficial_calculateField(fN);
	}
	function establecerSubcuenta() {
		this.ctx.oficial_establecerSubcuenta();
	}
	function toolButtonInsertSub_clicked() {
		this.ctx.oficial_toolButtonInsertSub_clicked();
	}
	function toolButtonDelSub_clicked() {
		this.ctx.oficial_toolButtonDelSub_clicked();
	}
	function imprimirPedido() {
		this.ctx.oficial_imprimirPedido();
	}
	function imprimirAlbaran() {
		this.ctx.oficial_imprimirAlbaran();
	}
	function imprimirFactura() {
		this.ctx.oficial_imprimirFactura();
	}
	function calcularSubcuentaPro(cursor:FLSqlCursor, longSubcuenta:Number):String {
		return this.ctx.oficial_calcularSubcuentaPro(cursor, longSubcuenta);
	}
	function insertContacto() {
		return this.ctx.oficial_insertContacto();
	}
	function deleteContacto() {
		return this.ctx.oficial_deleteContacto();
	}
	function deleteContactoAsociado() {
		return this.ctx.oficial_deleteContactoAsociado();
	}
	function insertContactoAsociado() {
		return this.ctx.oficial_insertContactoAsociado();
	}
	function lanzarEdicionContacto() {
		return this.ctx.oficial_lanzarEdicionContacto();
	}
	function buscarContacto() {
		return this.ctx.oficial_buscarContacto();
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
	function pub_calcularSubcuentaPro(cursor:FLSqlCursor, longSubcuenta:Number):String {
		return this.calcularSubcuentaPro(cursor, longSubcuenta);
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
/** \C En caso de que el módulo principal de contabilidad esté cargado, la pestaña 'contabilidad' del formulario queda habilitada. Al crearse un proveedor se creará automáticamente una subcuenta asociada, cuyo código por defecto estará formado por el código de la cuenta especial de proveedores + ceros de relleno para completar la longitud de subcuenta + código del proveedor

En la pestaña 'documentos' se encuentran los listados de documentos asociados al proveedor. Todos estos datos se presentan en módo de solo lectura
 
Cada proveedor puede tener un conjunto de direcciones, una de las cuales se establece como principal. La dirección principal aparecerá por defecto en los documentos de facturación (albaranes, facturas, etc). No podrá haber más de una dirección principal.
\end */
function interna_init()
{
	var util:FLUtil = new FLUtil;
	
	this.child("tdbFacturas").setEditOnly(true);
	this.child("tdbAlbaranes").setEditOnly(true);
	this.child("tdbPedidos").setEditOnly(true);
	
	this.iface.toolButtonInsertSub = this.child("toolButtonInsertSub");
	this.iface.toolButtonDelSub = this.child("toolButtonDeleteSub");
	this.child("tdbSubcuentas").setReadOnly(true);

	this.iface.toolButtonInsertContacto = this.child("tbInsertContacto");
	this.iface.toolButtonDeleteContacto = this.child("tbDeleteContacto");
	this.iface.toolButtonDeleteContactoProveedor = this.child("toolButtonDeleteContactoProveedor");
	this.iface.toolButtonInsertContactoProveedor = this.child("toolButtonInsertContactoProveedor");
	this.iface.toolButtonBuscarContacto = this.child("toolButtonBuscarContacto");
	
	this.iface.ejercicioActual = flfactppal.iface.pub_ejercicioActual();
	this.iface.posActualPuntoSubcuenta = -1;
	this.iface.longSubcuenta = util.sqlSelect("ejercicios", "longsubcuenta", "codejercicio = '" + this.iface.ejercicioActual + "'");

	var cursor:FLSqlCursor = this.cursor();
	if (cursor.modeAccess() == cursor.Insert) {
		this.child("fdbCodDivisa").setValue(flfactppal.iface.pub_valorDefectoEmpresa("coddivisa"));
		this.child("fdbCodPago").setValue(flfactppal.iface.pub_valorDefectoEmpresa("codpago"));
		this.child("fdbCodSerie").setValue(flfactppal.iface.pub_valorDefectoEmpresa("codserie"));
		if (sys.isLoadedModule("flcontppal"))
			this.iface.bufferChanged("codproveedor");
	}

	connect(this.child("toolButtonPrintPed"), "clicked()", this, "iface.imprimirPedido()");
	connect(this.child("toolButtonPrintAlb"), "clicked()", this, "iface.imprimirAlbaran()");
	connect(this.child("toolButtonPrintFac"), "clicked()", this, "iface.imprimirFactura()");
	
	connect(this.child("pbDireccion"), "clicked()", this, "iface.cambiarDireccion()");
	connect(this.child("tdbDirecciones").cursor(), "cursorUpdated()", this, "iface.cargarDireccion()");
	connect(this.child("pbNuevaDireccion"), "clicked()", this.child("tdbDirecciones"), "insertRecord()");
	connect(cursor, "bufferChanged(QString)", this, "iface.bufferChanged");
	connect(this.child("tdbSubcuentas").cursor(), "newBuffer()", this, "iface.establecerSubcuenta()");
	connect(this.iface.toolButtonInsertSub, "clicked()", this, "iface.toolButtonInsertSub_clicked()");
	connect(this.iface.toolButtonDelSub, "clicked()", this, "iface.toolButtonDelSub_clicked()");

	connect(this.iface.toolButtonInsertContacto, "clicked()", this, "iface.insertContacto()");
	connect(this.iface.toolButtonDeleteContacto, "clicked()", this, "iface.deleteContacto()");
	connect(this.iface.toolButtonDeleteContactoProveedor, "clicked()", this, "iface.deleteContactoAsociado()");
	connect(this.iface.toolButtonInsertContactoProveedor, "clicked()", this, "iface.insertContactoAsociado()");
	connect(this.child("toolButtonEdit"), "clicked()", this, "iface.lanzarEdicionContacto()");
	connect(this.child("toolButtonBuscarContacto"), "clicked()", this, "iface.buscarContacto()");

	this.child("tdbContactos").cursor().setMainFilter("codcontacto IN(SELECT codcontacto FROM contactosproveedores WHERE codproveedor = '" + cursor.valueBuffer("codproveedor") + "')");
	this.child("tdbContactos").setReadOnly(false);

	this.iface.cargarDireccion();
	
	if (sys.isLoadedModule("flcontppal")) {
		this.iface.establecerSubcuenta();
		this.child("tdbPartidas").setReadOnly(true);
	} else {
		this.child("tbwProveedor").setTabEnabled("contabilidad", false);
	}

	// Gestión documental
	if (sys.isLoadedModule("flcolagedo")) {
		var datosGD:Array;
		datosGD["txtRaiz"] = cursor.valueBuffer("codproveedor") + ": " + cursor.valueBuffer("nombre");
		datosGD["tipoRaiz"] = "proveedores";
		datosGD["idRaiz"] = cursor.valueBuffer("codproveedor");
		flcolagedo.iface.pub_gestionDocumentalOn(this, datosGD);
	} else {
		this.child("tbwDocumentos").setTabEnabled("gesdocu", false);
	}
}

function interna_calculateCounter():String
{
	var util:FLUtil = new FLUtil();
	return util.nextCounter("codproveedor", this.cursor());
}

//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
/** \D Establece la dirección seleccionada en la tabla como dirección principal
\end */
function oficial_cambiarDireccion()
{
	var cursor:FLSqlCursor = this.child("tdbDirecciones").cursor();
	var codProveedor:String = cursor.valueBuffer("codproveedor");

	var cursorBorrar:FLSqlCursor = new FLSqlCursor("dirproveedores");
	cursorBorrar.select("codproveedor = '" + codProveedor + "' AND direccionppal = 'true'");
	cursorBorrar.first();
	cursorBorrar.setModeAccess(cursorBorrar.Edit);
	cursorBorrar.refreshBuffer();
	cursorBorrar.setValueBuffer("direccionppal", "false");
	cursorBorrar.commitBuffer();

	cursor.setModeAccess(cursor.Edit);
	cursor.refreshBuffer();
	cursor.setValueBuffer("direccionppal", "true");
	cursor.commitBuffer();

	this.child("tdbDirecciones").refresh();

	this.iface.cargarDireccion();
}

/** \D Carga la dirección principal desde la tabla de direcciones de proveedores al campo de texto del formulario. Es llamado al inicio de la carga del formulario o cuando cambia el domicilio principal
\end */
function oficial_cargarDireccion()
{
	var label:String = this.child("lblDireccion");
	var textLabel:String;
	var botonNueva:Object = this.child("pbNuevaDireccion");
	var cursor:FLSqlCursor = new FLSqlCursor("dirproveedores");
	var partesDireccion:Array = ["descripcion", "direccion", "codpostal", "ciudad", "provincia", "codpais"];

	cursor.select("codproveedor = '" + this.cursor().valueBuffer("codproveedor") + "' AND direccionppal = 'true'");
	if (cursor.first()) {
		botonNueva.setEnabled(false);
		cursor.refreshBuffer();
		textLabel = "";
		for (i = 0; i < partesDireccion.length; i++) {
			if (cursor.valueBuffer(partesDireccion[i])) {
				if (i > 0)
					textLabel = textLabel + "\n";
				textLabel = textLabel + cursor.valueBuffer(partesDireccion[i]);
			}
		}
		label.setText(textLabel);
	} else {
		botonNueva.setEnabled(true);
		label.setText("");
	}
}

function oficial_bufferChanged(fN:String)
{
	var cursor:FLSqlCursor = this.cursor();
	switch(fN) {
	/** \C
	Al introducir --codsubcuenta--, si el usuario pulsa la tecla "punto" (.), la subcuenta se informa automaticamente con el código de cuenta más tantos ceros como sea necesario para completar la longitud de subcuenta asociada al ejercicio actual.
	\end */
		case "codsubcuenta": {
			if (!this.iface.bloqueoSubcuenta) {
				this.iface.bloqueoSubcuenta = true;
				this.iface.posActualPuntoSubcuenta = flcontppal.iface.pub_formatearCodSubcta(this, "fdbCodSubcuenta", this.iface.longSubcuenta, this.iface.posActualPuntoSubcuenta);
				this.iface.bloqueoSubcuenta = false;
			}
			var codSubcuenta:String = this.child("fdbCodSubcuenta").value();
			break;
		}
	/** \C
    El valor de --codsubcuenta-- en modo de inserción será 400 + el código de proveedor, más los ceros intermedios necesarios para completar la longitud de subcuenta establecida para el ejercicio actual.
	\end */
		case "codproveedor": {
			if (cursor.modeAccess() == cursor.Insert) {
				this.iface.bloqueoSubcuenta = true;
				this.child("fdbCodSubcuenta").setValue(this.iface.calculateField("codsubcuenta"));
				this.iface.bloqueoSubcuenta = false;
			}
			break;
		}
	}
}

/** \D Gestiona los datos de contabilidad de la subcuenta asociada al proveedor
\end */
function oficial_calculateField(fN:String):String
{
	var util:FLUtil = new FLUtil();
	var cursor:FLSqlCursor = this.cursor();
	var res:String;

	switch (fN) {
		case "codsubcuenta": {
			res = this.iface.calcularSubcuentaPro(cursor, this.iface.longSubcuenta);
			break;
		}
	}
	return res;
}

function oficial_calcularSubcuentaPro(cursor:FLSqlCursor, longSubcuenta:Number):String
{
	var util:FLUtil = new FLUtil();
	var codSubcuenta:String = util.sqlSelect("co_cuentas", "codcuenta", "idcuentaesp = 'PROVEE' ORDER BY codcuenta");
	if (!codSubcuenta)
		return false;

	var codProveedor:String = cursor.valueBuffer("codproveedor");
	if (!codProveedor)
		codProveedor = "";
		
	var numCeros:Number = longSubcuenta - codSubcuenta.length - codProveedor.length;
	for (var i:Number = 0; i < numCeros; i++)
		codSubcuenta += "0";
	
	if (codSubcuenta.length + codProveedor.length > this.iface.longSubcuenta)
		codProveedor = codProveedor.right(this.iface.longSubcuenta - codSubcuenta.length);
	
	codSubcuenta += codProveedor;
	return codSubcuenta;
}

/** \C Al seleccionar un registro de la tabla de subcuentas por ejercicio, la pestaña de Contabilidad muestra los datos relativos a la subcuenta seleccionada */
function oficial_establecerSubcuenta()
{
	if (!sys.isLoadedModule("flcontppal"))
		return false;
	
	var util:FLUtil = new FLUtil;
	var curSubcuenta:FLSqlCursor = this.child("tdbSubcuentas").cursor();

	if (!curSubcuenta.isValid())
		this.cursor().setNull("idsubcuenta");
	else
		this.cursor().setValueBuffer("idsubcuenta", curSubcuenta.valueBuffer("idsubcuenta"));
	
	this.child("tdbPartidas").refresh();
}

/** \C Para insertar una subcuenta asociada al proveedor actual, el usuario debe seleccionar el ejercicio al que irá asociada dicha subcuenta */
function oficial_toolButtonInsertSub_clicked()
{
	var cursor:FLSqlCursor = this.cursor();
	var util:FLUtil = new FLUtil;

	if (cursor.modeAccess() == cursor.Insert) {
		var curSubcuentas:FLSqlCursor = this.child("tdbSubcuentas").cursor();
		curSubcuentas.setModeAccess(curSubcuentas.Insert);
		curSubcuentas.commitBufferCursorRelation();
		this.child("tdbSubcuentas").refresh();
		return;
	}

	var codSubcuenta:String = cursor.valueBuffer("codsubcuenta");
	if (!codSubcuenta || codSubcuenta == "") {
		MessageBox.warning(util.translate("scripts", "Especifique el código de subcuenta a crear en el campo Subcuenta"), MessageBox.Ok, MessageBox.NoButton);
		return;
	}

	var formEjercicios:Object = new FLFormSearchDB("ejercicios");
	var curEjercicios:FLSqlCursor = formEjercicios.cursor();

	formEjercicios.setMainWidget();
	var codEjercicio:String = formEjercicios.exec("codejercicio");

	if (codEjercicio) {
		if (!util.sqlSelect("co_epigrafes", "idepigrafe", "codejercicio = '" + codEjercicio + "'")) {
			MessageBox.warning(util.translate("scripts", "No existe plan general contable para el ejercicio seleccionado"), MessageBox.Ok, MessageBox.NoButton);
			return;
		}
		
		var longSubcuenta:Number = util.sqlSelect("ejercicios", "longsubcuenta", "codejercicio = '" + codEjercicio + "'");
		if (!longSubcuenta || longSubcuenta != codSubcuenta.length) {
			MessageBox.warning(util.translate("scripts", "La longitud de la subcuenta no coincide con la establecida para el ejercicio seleccionado"), MessageBox.Ok, MessageBox.NoButton);
			return;
		}
		var idSubcuenta:String = flfactppal.iface.pub_crearSubcuenta(codSubcuenta, cursor.valueBuffer("nombre"), "PROVEE", codEjercicio);
		if (!idSubcuenta) {
			MessageBox.critical(util.translate("scripts", "Hubo un error al crear la subcuenta"), MessageBox.Ok, MessageBox.NoButton);
			return false;
		}
		flfactppal.iface.pub_crearSubcuentaProv(codSubcuenta, idSubcuenta, cursor.valueBuffer("codproveedor"), codEjercicio);

		this.child("tdbSubcuentas").refresh();
	}
}

/** \D Borra la vinculación proveedor - subcuenta seleccionada, ofreciendo la posibilidad de borrar también la subcuenta si ésta está vacía 
\end */
function oficial_toolButtonDelSub_clicked()
{
	var curTablaSub:FLSqlCursor = this.child("tdbSubcuentas").cursor();
	if (!curTablaSub.isValid())
		return;
	var idSubcuenta:String = curTablaSub.valueBuffer("idsubcuenta");
	
	var util:FLUtil = new FLUtil;
	var res = MessageBox.information(util.translate("scripts", "Va a eliminar la vinculación de la subcuenta seleccionada al proveedor actual."), MessageBox.Ok, MessageBox.Cancel);
	if (res != MessageBox.Ok)
		return;
	
	var saldo:Number = util.sqlSelect("co_subcuentas", "saldo", "idsubcuenta = " + idSubcuenta);
	if (saldo == 0) {
		if (!util.sqlSelect("co_partidas", "idpartida", "idsubcuenta = " + idSubcuenta)) {
			if (!util.sqlSelect("co_subcuentasprov", "idsubcuenta", "idsubcuenta = " + idSubcuenta + " AND codproveedor <> '" + this.cursor().valueBuffer("codproveedor") + "'")) {
				var res = MessageBox.information(util.translate("scripts", "La subcuenta seleccionada no contiene ninguna partida ni está vinculada a otro proveedor.\n¿Desea eliminarla junto con la vinculación?"), MessageBox.Yes, MessageBox.No);
				if (res == MessageBox.Yes) {
					util.sqlDelete("co_subcuentas", "idsubcuenta = " + idSubcuenta);
					this.child("tdbSubcuentas").refresh();
					this.iface.establecerSubcuenta();
					return;
				}
			}
		}
	}
	
	util.sqlDelete("co_subcuentasprov", "id = " + curTablaSub.valueBuffer("id"));
	this.child("tdbSubcuentas").refresh();
	this.iface.establecerSubcuenta();
}

/** \D Imprime el pedido seleccionado
\end */
function oficial_imprimirPedido()
{
	var codPedido:String = this.child("tdbPedidos").cursor().valueBuffer("codigo");
	if (!codPedido)
		return;
	formpedidosprov.iface.pub_imprimir(codPedido);
}
/** \D Imprime el albarán seleccionado
\end */
function oficial_imprimirAlbaran()
{
	var codAlbaran:String = this.child("tdbAlbaranes").cursor().valueBuffer("codigo");
	if (!codAlbaran)
		return;
	formalbaranesprov.iface.pub_imprimir(codAlbaran);
}
/** \D Imprime la factura seleccionada
\end */
function oficial_imprimirFactura()
{
	var codFactura:String = this.child("tdbFacturas").cursor().valueBuffer("codigo");
	if (!codFactura)
		return;
	formfacturasprov.iface.pub_imprimir(codFactura);
}

function oficial_insertContacto()
{
	var f:Object;

	if (this.cursor().modeAccess() == this.cursor().Insert) {
		if (!this.child("tdbDirecciones").cursor().commitBufferCursorRelation())
			return false;
	}

	f = new FLFormSearchDB("editcontacto");
	var codigo:String = this.cursor().valueBuffer("codproveedor");
	
	var curContactos:FLSqlCursor = f.cursor();
	
	curContactos.setModeAccess(curContactos.Insert);
	curContactos.refreshBuffer();
	
	f.setMainWidget();
	curContactos.refreshBuffer();
	f.exec("codcontacto");

	if (f.accepted()) {
		if (!curContactos.commitBuffer())
			return;
		
		var curContactoProv:FLSqlCursor = new FLSqlCursor("contactosproveedores");
		curContactoProv.setModeAccess(curContactoProv.Insert);
		curContactoProv.refreshBuffer();
		curContactoProv.setValueBuffer("codcontacto",curContactos.valueBuffer("codcontacto"));
		curContactoProv.setValueBuffer("codproveedor",codigo);
		
		if (!curContactoProv.commitBuffer())
			return false;
	}
}

function oficial_deleteContacto()
{
	var util:FLUtil;
	var f:Object;
	f = new FLFormSearchDB("editcontacto");
	var codigo:String = this.child("tdbContactos").cursor().valueBuffer("codcontacto");
	if (!codigo || codigo == "") {
		MessageBox.information(util.translate("scripts", "No hay ningún registro seleccionado."), MessageBox.Ok, MessageBox.NoButton);
		return;
	}
	var codAsociado:String = this.cursor().valueBuffer("codProveedor");

	var curContactos:FLSqlCursor = f.cursor(); 
	var preguntar:Boolean = false;
	if(util.sqlSelect("contactosproveedores","codcontacto","codcontacto = '" + codigo + "' AND codproveedor <> '" + codAsociado + "'") || util.sqlSelect("contactosclientes","codcontacto","1 = 1"))
			preguntar = true;
	
	if (preguntar) {
		var res:String = MessageBox.information(util.translate("scripts", "El contacto seleccionado está vinculado a otros registros. Si lo elimina se eliminarán todas las vinculaciones. ¿Desea continuar?"), MessageBox.Yes, MessageBox.No);
			if (res != MessageBox.Yes)
				return;
	}
	else {
			var res:String = MessageBox.information(util.translate("scripts", "El registro seleccionado será borrado. ¿Está seguro?"), MessageBox.Yes, MessageBox.No);
			if (res != MessageBox.Yes)
				return;
	}
	
	curContactos.select("codcontacto = '" + codigo + "'");
	if (!curContactos.first())
		return false;
	curContactos.setModeAccess(curContactos.Del);
	curContactos.refreshBuffer();
	curContactos.commitBuffer();
}

function oficial_deleteContactoAsociado()
{
	var util:FLUtil;
	var f:Object;
	f = new FLFormSearchDB("editcontactoprov");
	var codigo:String = this.child("tdbContactos").cursor().valueBuffer("codcontacto");

	var curContactos:FLSqlCursor = f.cursor();

	curContactos.select("codcontacto = '" + codigo + "'");
	if (!curContactos.first())
		return false;
	curContactos.setModeAccess(curContactos.Del);
	curContactos.refreshBuffer();
	var res:String;
	res = MessageBox.information(util.translate("scripts", "Se va a desvincular el contacto seleccionado del proveedor. ¿Está seguro?"), MessageBox.Yes, MessageBox.No);
	if (res != MessageBox.Yes)
		return;

	curContactos.commitBuffer();
}

function oficial_insertContactoAsociado()
{
	if (this.cursor().modeAccess() == this.cursor().Insert) {
		if (!this.child("tdbDirecciones").cursor().commitBufferCursorRelation())
			return false;
	}

	var f:Object = new FLFormSearchDB("insertcontacto");;
	var codAsociado:String = this.cursor().valueBuffer("codproveedor");

	f.setMainWidget();
	var codContacto:String = f.exec("codcontacto");
	if(!codContacto)
		return;

	if (f.accepted()) {
		var curContactoProv:FLSqlCursor = new FLSqlCursor("contactosproveedores");
		curContactoProv.setModeAccess(curContactoProv.Insert);
		curContactoProv.refreshBuffer();
		curContactoProv.setValueBuffer("codcontacto",codContacto);
		curContactoProv.setValueBuffer("codproveedor",codAsociado);
		
		if (!curContactoProv.commitBuffer())
			return false;
	}
}

function oficial_lanzarEdicionContacto()
{
	var util:FLUtil;
	var codContacto:String = this.child("fdbCodContacto").value();
	
	var f:Object = new FLFormSearchDB("editcontacto");
	var curContactos:FLSqlCursor = f.cursor();
	var codNuevoContacto:String;
	var insert:Boolean = false;
	var cursor:FLSqlCursor = this.cursor();
	if (cursor.modeAccess() == cursor.Insert) {
		if (!this.child("tdbDirecciones").cursor().commitBufferCursorRelation())
			return false;
	}
	
	if (codContacto && codContacto != "") {
		curContactos.select("codcontacto = '" + codContacto + "'");
		if (!curContactos.first()) {
			MessageBox.warning(util.translate("scripts", "El contacto " + codContacto + " no existe en la tabla de contactos.\nSi quiere crear uno nuevo deje el codigo en blanco y vuelva a pulsar el botón."), MessageBox.Ok, MessageBox.NoButton);
			return false;
		}
		curContactos.setModeAccess(curContactos.Edit);
	}
	else {
		insert = true;
		curContactos.setModeAccess(curContactos.Insert);
		curContactos.refreshBuffer();
	}
	
	f.setMainWidget();
	curContactos.refreshBuffer();
	f.exec("codcontacto");

	if (f.accepted()) {
		curContactos.commitBuffer();
		codNuevoContacto = curContactos.valueBuffer("codcontacto");
	
	}
	if (!codNuevoContacto)
		return;
	
	this.child("fdbCodContacto").setValue("");
	this.child("fdbCodContacto").setValue(codNuevoContacto);

	if (insert) { 
		var codProveedor:String = this.cursor().valueBuffer("codproveedor");

		if (!codProveedor || codProveedor == "")
			return;

// 		if(!this.iface.crearContactoTarjeta(codNuevoContacto,codTarjeta))
// 			return;

		var curProvCon:FLSqlCursor = new FLSqlCursor("contactosproveedores");
		with(curProvCon) {
			setModeAccess(Insert);
			refreshBuffer();
			setValueBuffer("codproveedor", codProveedor);
			setValueBuffer("codcontacto", codNuevoContacto);
			if (!commitBuffer())
				return false;
		}
		return true;
	}
}

function oficial_buscarContacto()
{
	var f:Object = new FLFormSearchDB("insertcontacto");;
	var codProveedor:String = this.cursor().valueBuffer("codproveedor");

	if(!codProveedor)
		return;

	f.setMainWidget();
	f.cursor().setMainFilter("codcontacto IN(SELECT codcontacto FROM contactosproveedores WHERE codproveedor = '" + codProveedor + "')");
	var codContacto:String = f.exec("codcontacto");
	if(!codContacto)
		return;

	this.cursor().setValueBuffer("codcontacto",codContacto);
}

//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
