/***************************************************************************
                 clientes.qs  -  description
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
	function validateForm():Boolean { return this.ctx.interna_validateForm(); }
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
	var ejercicioActual:String;
	var longSubcuenta:String;
	var bloqueoSubcuenta:Boolean;
	var posActualPuntoSubcuenta:Number;
	var toolButtonInsertSub:Object;
	var toolButtonDelSub:Object;
	var toolButtonInsertContacto:Object;
	var toolButtonDeleteContacto:Object;
	var toolButtonDeleteContactoCliente:Object;
	var toolButtonInsertContactoCliente:Object;
	var toolButtonBuscarContacto:Object;

	function oficial( context ) { interna( context ); } 
	function cambiarDomFacturacion() {
		this.ctx.oficial_cambiarDomFacturacion();
	}
	function cambiarDomEnvio() {
		this.ctx.oficial_cambiarDomEnvio();
	}
	function cambiarDom(tipo) {
		this.ctx.oficial_cambiarDom(tipo);
	}
	function cargarDomFacturacion() {
		this.ctx.oficial_cargarDomFacturacion();
	}
	function bufferChanged(fN:String) {
		this.ctx.oficial_bufferChanged(fN);
	}
	function calculateField(fN:String) {
		return this.ctx.oficial_calculateField(fN);
	}
	function cambiarCuentaDom() {
		this.ctx.oficial_cambiarCuentaDom();
	}
	function borrarCuentaDom() {
		this.ctx.oficial_borrarCuentaDom();
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
	function imprimirPresupuesto() {
		this.ctx.oficial_imprimirPresupuesto();
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
	function imprimirRecibo() {
		this.ctx.oficial_imprimirRecibo();
	}
	function calcularSubcuentaCli(cursor:FLSqlCursor, longSubcuenta:Number):String {
		return this.ctx.oficial_calcularSubcuentaCli(cursor, longSubcuenta);
	}
	function mostrarDesCuentaDom() {
		return this.ctx.oficial_mostrarDesCuentaDom();
	}
	function insertContacto(accion:String,codigo:String) {
		return this.ctx.oficial_insertContacto(accion,codigo);
	}
	function deleteContacto(accion:String,codigo:String,codAsociado:String) {
		return this.ctx.oficial_deleteContacto(accion,codigo,codAsociado);
	}
	function deleteContactoAsociado(accion:String,codigo:String) {
		return this.ctx.oficial_deleteContactoAsociado(accion,codigo);
	}
	function insertContactoAsociado(accion:String,codigo:String) {
		return this.ctx.oficial_insertContactoAsociado(accion,codigo);
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
	function pub_calcularSubcuentaCli(cursor:FLSqlCursor, longSubcuenta:Number):String {
		return this.calcularSubcuentaCli(cursor, longSubcuenta);
	}
	function pub_insertContacto(accion:String,codigo:String) {
		return this.insertContacto(accion,codigo);
	}
	function pub_deleteContacto(accion:String,codigo:String,codAsociado:String) {
		return this.deleteContacto(accion,codigo,codAsociado);
	}
	function pub_deleteContactoAsociado(accion:String,codigo:String) {
		return this.deleteContactoAsociado(accion,codigo);
	}
	function pub_insertContactoAsociado(accion:String,codigo:String) {
		return this.insertContactoAsociado(accion,codigo);
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
/** \D En el caso de el módulo principal de contabilidad esté cargado, el sistema actuará de la siguiente manera:

Al crearse un cliente se creará automáticamente una subcuenta asociada, cuyo código por defecto estará formado por	código de la cuenta especial de clientes + ceros de relleno para completar la longitud de subcuenta + código del cliente
\end */
function interna_init()
{
/** \C En la pestaña 'documentos' se encuentran los listados de documentos asociados al cliente. Todos estos datos se presentan en módo de solo lectura
 
Si está cargado el módulo de contabilidad, se habilita la pestaña 'contabilidad' del formulario

Cada cliente puede tener un conjunto de direcciones, de las cuales existen dos especiales. La dirección de facturación aparecerá por defecto en los documentos de facturación (albaranes, facturas, etc). La dirección de envío podrá utilizarse como dirección de destino postal o de paquetería. Una misma dirección puede ser de los dos tipos. No podrá haber más de una dirección de facturación ni de envío.

\end */
	var util:FLUtil = new FLUtil;
	
	var cursor:FLSqlCursor = this.cursor();
	this.child("tdbFacturas").setEditOnly(true);
	this.child("tdbAlbaranes").setEditOnly(true);
	this.child("tdbPedidos").setEditOnly(true);
	this.child("tdbPresupuestos").setEditOnly(true);
	this.child("tdbRecibos").setEditOnly(true);
	
	this.iface.toolButtonInsertContacto = this.child("toolButtonInsertContacto");
	this.iface.toolButtonDeleteContacto = this.child("toolButtonDeleteContacto");
	this.iface.toolButtonDeleteContactoCliente = this.child("toolButtonDeleteContactoCliente");
	this.iface.toolButtonInsertContactoCliente = this.child("toolButtonInsertContactoCliente");
	this.iface.toolButtonBuscarContacto = this.child("toolButtonBuscarContacto");
	
	this.iface.toolButtonInsertSub = this.child("toolButtonInsertSub");
	this.iface.toolButtonDelSub = this.child("toolButtonDeleteSub");
	this.child("tdbSubcuentas").setReadOnly(true);
	
	this.iface.ejercicioActual = flfactppal.iface.pub_ejercicioActual();
	this.iface.longSubcuenta = util.sqlSelect("ejercicios", "longsubcuenta",
		"codejercicio = '" + this.iface.ejercicioActual + "'");
	this.iface.posActualPuntoSubcuenta = -1;

	connect(this.child("toolButtonPrintPre"), "clicked()", this, "iface.imprimirPresupuesto()");
	connect(this.child("toolButtonPrintPed"), "clicked()", this, "iface.imprimirPedido()");
	connect(this.child("toolButtonPrintAlb"), "clicked()", this, "iface.imprimirAlbaran()");
	connect(this.child("toolButtonPrintFac"), "clicked()", this, "iface.imprimirFactura()");
	connect(this.child("toolButtonPrintRec"), "clicked()", this, "iface.imprimirRecibo()");
	
	connect(this.child("pbDomFacturacion"), "clicked()", this, "iface.cambiarDomFacturacion()");
	connect(this.child("pbDomEnvio"), "clicked()", this, "iface.cambiarDomEnvio()");
	connect(this.child("tdbDirecciones").cursor(), "cursorUpdated()", this, "iface.cargarDomFacturacion()");
	connect(this.child("pbNuevoDomFacturacion"), "clicked()", this.child("tdbDirecciones"), "insertRecord()");
	connect(cursor, "bufferChanged(QString)", this, "iface.bufferChanged");
 	
	connect(this.child("pbnCuentaDom"), "clicked()", this, "iface.cambiarCuentaDom()");
	connect(this.child("pbnBorrarCuentaDom"), "clicked()", this, "iface.borrarCuentaDom()");
	this.child("gbxCuentaDom").setDisabled(true);
	
	connect(this.child("tdbSubcuentas").cursor(), "newBuffer()", this, "iface.establecerSubcuenta()");
	connect(this.iface.toolButtonInsertSub, "clicked()", this, "iface.toolButtonInsertSub_clicked()");
	connect(this.iface.toolButtonDelSub, "clicked()", this, "iface.toolButtonDelSub_clicked()");

	connect(this.iface.toolButtonInsertContacto, "clicked()", this, "iface.insertContacto()");
	connect(this.iface.toolButtonDeleteContacto, "clicked()", this, "iface.deleteContacto()");
	connect(this.iface.toolButtonDeleteContactoCliente, "clicked()", this, "iface.deleteContactoAsociado()");
	connect(this.iface.toolButtonInsertContactoCliente, "clicked()", this, "iface.insertContactoAsociado()");
	connect(this.child("toolButtonEdit"), "clicked()", this, "iface.lanzarEdicionContacto()");
	connect(this.child("toolButtonBuscarContacto"), "clicked()", this, "iface.buscarContacto()");

// 	this.child("fdbCodContacto").setFilter("codcontacto IN(SELECT codcontacto FROM contactosclientes WHERE codcliente = '" + cursor.valueBuffer("codcliente") + "')");

	this.child("tdbContactos").cursor().setMainFilter("codcontacto IN(SELECT codcontacto FROM contactosclientes WHERE codcliente = '" + cursor.valueBuffer("codcliente") + "')");
	this.child("tdbContactos").setReadOnly(false);

	/** \D Se carga el domicilio de facturación
	\end */
	this.iface.cargarDomFacturacion();

	/** \C En modo inserción, los campos --coddivisa--, --codpago--, --codcuentarem-- y --codserie-- toman los valores por defecto definidos para la empresa
	\end */
	if (cursor.modeAccess() == cursor.Insert) {
		/*
		this.child("fdbCodDivisa").setValue(flfactppal.iface.pub_valorDefectoEmpresa("coddivisa"));
		this.child("fdbCodPago").setValue(flfactppal.iface.pub_valorDefectoEmpresa("codpago"));
		this.child("fdbCodCuentaRem").setValue(flfactppal.iface.pub_valorDefectoEmpresa("codcuentarem"));
		this.child("fdbCodSerie").setValue(flfactppal.iface.pub_valorDefectoEmpresa("codserie"));
		*/
		cursor.setValueBuffer("coddivisa", flfactppal.iface.pub_valorDefectoEmpresa("coddivisa"));
		cursor.setValueBuffer("codpago", flfactppal.iface.pub_valorDefectoEmpresa("codpago"));
		cursor.setValueBuffer("codcuentarem", flfactppal.iface.pub_valorDefectoEmpresa("codcuentarem"));
		cursor.setValueBuffer("codserie", flfactppal.iface.pub_valorDefectoEmpresa("codserie"));
		if (sys.isLoadedModule("flcontppal"))
			this.iface.bufferChanged("codcliente");
	} else {
		this.iface.mostrarDesCuentaDom();
	}

	/** \C Si está cargado el módulo de contabilidad, se habilita la pestaña 'contabilidad' del formulario
	\end */
	if (sys.isLoadedModule("flcontppal")) {
		this.iface.establecerSubcuenta();
		this.child("tdbPartidas").setReadOnly(true);
	} else {
		this.child("tbwCliente").setTabEnabled("contabilidad", false);
	}
	
	this.iface.bufferChanged("debaja");

	// Gestión documental
	if (sys.isLoadedModule("flcolagedo")) {
		var datosGD:Array;
		datosGD["txtRaiz"] = cursor.valueBuffer("codcliente") + ": " + cursor.valueBuffer("nombre");
		datosGD["tipoRaiz"] = "clientes";
		datosGD["idRaiz"] = cursor.valueBuffer("codcliente");
		flcolagedo.iface.pub_gestionDocumentalOn(this, datosGD);
	} else {
		this.child("tbwDocumentos").setTabEnabled("gesdocu", false);
	}

	if (sys.isLoadedModule("flcrm_ppal"))
		this.child("tdbContactos").cursor().setAction("crm_contactos");
	else
		this.child("tdbContactos").cursor().setAction("contactos");
}

/** \D Calcula un nuevo código de cliente
\end */
function interna_calculateCounter()
{
		var util:FLUtil = new FLUtil();
		return util.nextCounter("codcliente", this.cursor());
}

function interna_validateForm():Boolean
{
	var cursor:FLSqlCursor = this.cursor();
	var util:FLUtil = new FLUtil;
	/** \C Si el cliente está de baja, la fecha de comienzo de la baja debe estar informada
	\end */
	if (cursor.valueBuffer("debaja") && cursor.isNull("fechabaja")) {
		MessageBox.warning(util.translate("scripts", "Si el cliente está de baja debe introducir la correspondiente fecha de inicio de la baja"), MessageBox.Ok, MessageBox.NoButton)
		return false;
	}

	return true;
}
//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
/** \D Marca el domicilio seleccionado en la lista como el de facturación
\end */
function oficial_cambiarDomFacturacion()
{
		this.iface.cambiarDom("domfacturacion");
}

/** \D Marca el domicilio seleccionado en la lista como el de envío
\end */
function oficial_cambiarDomEnvio()
{
		this.iface.cambiarDom("domenvio");
}

/** \D Marca el domicilio seleccionado en la lista como el de facturación o envío modificando la tabla de direcciones de cliente

@param tipo Tipo de dirección (facturación o envío)
\end */
function oficial_cambiarDom(tipo)
{
		var cursor:FLSqlCursor = this.child("tdbDirecciones").cursor();
		var cursorBorrar:FLSqlCursor = new FLSqlCursor("dirclientes");

		cursorBorrar.select("codcliente = '" + cursor.valueBuffer("codcliente") + "' AND " + tipo + " = 'true'");
		cursorBorrar.first();
		cursorBorrar.setModeAccess(cursorBorrar.Edit);
		cursorBorrar.refreshBuffer();
		cursorBorrar.setValueBuffer(tipo, "false");
		cursorBorrar.commitBuffer();

		cursor.setModeAccess(cursor.Edit);
		cursor.refreshBuffer();
		cursor.setValueBuffer(tipo, "true");
		cursor.commitBuffer();

		this.child("tdbDirecciones").refresh();

		this.iface.cargarDomFacturacion();
}

/** \D Carga el domicilio de facturación desde la tabla de direcciones de clientes al campo de texto del formulario. Es llamado al inicio de la carga del formulario o cuando cambia el domicilio de facturación
\end */
function oficial_cargarDomFacturacion()
{
		var label:String = this.child("lblDomFacturacion");
		var textLabel:String;
		var botonNuevo:Object = this.child("pbNuevoDomFacturacion");
		var cursor:FLSqlCursor = new FLSqlCursor("dirclientes");
		var partesDireccion:Array = ["descripcion", "direccion", "codpostal", "ciudad", "provincia", "codpais"];

		cursor.select("codcliente = '" + this.cursor().valueBuffer("codcliente") + "' AND domfacturacion = 'true'");
		if (cursor.first()) {
				botonNuevo.setEnabled(false);
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
				botonNuevo.setEnabled(true);
				label.setText("");
		}
}

function oficial_bufferChanged(fN)
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
	El valor de --codsubcuenta-- en modo de inserción será 430 + el código de cliente, más los ceros intermedios necesarios para completar la longitud de subcuenta establecida para el ejercicio actual.
	\end */
		case "codcliente": {
			if (cursor.modeAccess() == cursor.Insert) {
				this.iface.bloqueoSubcuenta = true;
				this.child("fdbCodSubcuenta").setValue(this.iface.calculateField("codsubcuenta"));
				this.iface.bloqueoSubcuenta = false;
			}
			break;
		}
		case "debaja": {
			this.child("fdbFechaBaja").setValue(this.iface.calculateField("fechabaja"));
			break;
		}
	}
}

/** \D Gestiona los datos de contabilidad de la subcuenta asociada al cliente
\end */
function oficial_calculateField(fN:String):String
{
	var util:FLUtil = new FLUtil();
	var cursor:FLSqlCursor = this.cursor();
	var res:String;
	
	switch (fN) {
		case "codsubcuenta": {
			res = this.iface.calcularSubcuentaCli(cursor, this.iface.longSubcuenta);
			break;
		}
		case "fechabaja": {
			if (cursor.valueBuffer("debaja")) {
				var hoy:Date = new Date;
				res = hoy.toString();
			} else
				res = "";
			break;
		}
	}
	return res;
}

function oficial_calcularSubcuentaCli(cursor:FLSqlCursor, longSubcuenta:Number):String
{
	var util:FLUtil = new FLUtil();
	var codSubcuenta:String = util.sqlSelect("co_cuentas", "codcuenta", "idcuentaesp = 'CLIENT' ORDER BY codcuenta");
	if (!codSubcuenta)
		return false;

	var codCliente:String = cursor.valueBuffer("codcliente");
	if (!codCliente)
		codCliente = "";
	var numCeros:Number = longSubcuenta - codSubcuenta.length - codCliente.length;
	for (var i:Number = 0; i < numCeros; i++)
		codSubcuenta += "0";

	if (codSubcuenta.length + codCliente.length > longSubcuenta)
		codCliente = codCliente.right(longSubcuenta - codSubcuenta.length);

	codSubcuenta += codCliente;
	return codSubcuenta;
}

function oficial_cambiarCuentaDom()
{
	var curCuenta:FLSqlCursor = this.child("tdbCuentas").cursor();
	var codCuentaDom = curCuenta.valueBuffer("codcuenta");
	var desCuentaDom = curCuenta.valueBuffer("descripcion");
	
	if (!codCuentaDom) return;
	
	this.cursor().setValueBuffer("codcuentadom", codCuentaDom);
	this.iface.mostrarDesCuentaDom();
	//this.child("leDescCuentaDom").text = " " + desCuentaDom;
	
	var util:FLUtil = new FLUtil;
	
	MessageBox.information(util.translate("scripts", "Se ha establecido \"%0\" como cuenta de domiciliación para este cliente").arg(desCuentaDom), MessageBox.Ok, MessageBox.NoButton);
	return;
}

function oficial_mostrarDesCuentaDom()
{
	var util:FLUtil = new FLUtil;
	var cursor:FLSqlCursor = this.cursor();
	var desCuentaDom:String = util.sqlSelect("cuentasbcocli", "descripcion", "codcuenta = '" + cursor.valueBuffer("codcuentadom") + "'");
	if (desCuentaDom)
		this.child("leDescCuentaDom").text = " " + desCuentaDom;
}

function oficial_borrarCuentaDom()
{
	this.cursor().setValueBuffer("codcuentadom", "");
	this.child("leDescCuentaDom").text = "";
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

/** \C Para insertar una subcuenta asociada al cliente actual, el usuario debe seleccionar el ejercicio al que irá asociada dicha subcuenta */
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
		var idSubcuenta:String = flfactppal.iface.pub_crearSubcuenta(codSubcuenta, cursor.valueBuffer("nombre"), "CLIENT", codEjercicio);
		if (!idSubcuenta) {
			MessageBox.critical(util.translate("scripts", "Hubo un error al crear la subcuenta"), MessageBox.Ok, MessageBox.NoButton);
			return false;
		}
		flfactppal.iface.pub_crearSubcuentaCli(codSubcuenta, idSubcuenta, cursor.valueBuffer("codcliente"), codEjercicio);
		
		this.child("tdbSubcuentas").refresh();
	}
}

/** \D Borra la vinculación cliente - subcuenta seleccionada, ofreciendo la posibilidad de borrar también la subcuenta si ésta está vacía 
\end */
function oficial_toolButtonDelSub_clicked()
{
	var curTablaSub:FLSqlCursor = this.child("tdbSubcuentas").cursor();
	if (!curTablaSub.isValid())
		return;
	var idSubcuenta:String = curTablaSub.valueBuffer("idsubcuenta");
		
	var util:FLUtil = new FLUtil;
	var res = MessageBox.information(util.translate("scripts", "Va a eliminar la vinculación de la subcuenta seleccionada al cliente actual."), MessageBox.Ok, MessageBox.Cancel);
	if (res != MessageBox.Ok)
		return;
	
	var saldo:Number = util.sqlSelect("co_subcuentas", "saldo", "idsubcuenta = " + idSubcuenta);
	if (saldo == 0) {
		if (!util.sqlSelect("co_partidas", "idpartida", "idsubcuenta = " + idSubcuenta)) {
			if (!util.sqlSelect("co_subcuentascli", "idsubcuenta", "idsubcuenta = " + idSubcuenta + " AND codcliente <> '" + this.cursor().valueBuffer("codcliente") + "'")) {
				var res = MessageBox.information(util.translate("scripts", "La subcuenta seleccionada no contiene ninguna partida ni está vinculada a otro cliente.\n¿Desea eliminarla junto con la vinculación?"), MessageBox.Yes, MessageBox.No);
				if (res == MessageBox.Yes) {
					util.sqlDelete("co_subcuentas", "idsubcuenta = " + idSubcuenta);
					this.child("tdbSubcuentas").refresh();
					this.iface.establecerSubcuenta();
					return;
				}
			}
		}
	}
	
	util.sqlDelete("co_subcuentascli", "id = " + curTablaSub.valueBuffer("id"));
	this.child("tdbSubcuentas").refresh();
	this.iface.establecerSubcuenta();
}

/** \D Imprime el presupuesto seleccionado
\end */
function oficial_imprimirPresupuesto()
{
	var codPresupuesto:String = this.child("tdbPresupuestos").cursor().valueBuffer("codigo");
	if (!codPresupuesto)
		return;
	formpresupuestoscli.iface.pub_imprimir(codPresupuesto);
}
/** \D Imprime el pedido seleccionado
\end */
function oficial_imprimirPedido()
{
	var codPedido:String = this.child("tdbPedidos").cursor().valueBuffer("codigo");
	if (!codPedido)
		return;
	formpedidoscli.iface.pub_imprimir(codPedido);
}
/** \D Imprime el albarán seleccionado
\end */
function oficial_imprimirAlbaran()
{
	var codAlbaran:String = this.child("tdbAlbaranes").cursor().valueBuffer("codigo");
	if (!codAlbaran)
		return;
	formalbaranescli.iface.pub_imprimir(codAlbaran);
}
/** \D Imprime la factura seleccionada
\end */
function oficial_imprimirFactura()
{
	var codFactura:String = this.child("tdbFacturas").cursor().valueBuffer("codigo");
	if (!codFactura)
		return;
	formfacturascli.iface.pub_imprimir(codFactura);
}
/** \D Imprime el recibo seleccionado
\end */
function oficial_imprimirRecibo()
{
	var codRecibo:String = this.child("tdbRecibos").cursor().valueBuffer("codigo");
	if (!codRecibo)
		return;
	formreciboscli.iface.pub_imprimir(codRecibo);
}

function oficial_insertContacto(accion:String,codigo:String)
{
	var cursor:FLSqlCursor = this.cursor();
	

	var f:Object;
	if (accion) 
		f = new FLFormSearchDB("crm_editcontacto");
	else {
		if (cursor.modeAccess() == cursor.Insert) {
			if (!this.child("tdbDirecciones").cursor().commitBufferCursorRelation())
				return false;
		}
		codigo = cursor.valueBuffer("codcliente");
		if (sys.isLoadedModule("flcrm_ppal"))
			f = new FLFormSearchDB("crm_editcontacto");
		else
			f = new FLFormSearchDB("editcontacto");
	}

	var curContactos:FLSqlCursor = f.cursor();
	
	curContactos.setModeAccess(curContactos.Insert);
	curContactos.refreshBuffer();
	
	f.setMainWidget();
	curContactos.refreshBuffer();
	f.exec("codcontacto");

	if (f.accepted()) {
		if (!curContactos.commitBuffer())
			return;
		if(accion == "crm_tarjetas") {
			var curContactoTarjeta:FLSqlCursor = new FLSqlCursor("crm_contactostarjeta");
			curContactoTarjeta.setModeAccess(curContactoTarjeta.Insert);
			curContactoTarjeta.refreshBuffer();
			curContactoTarjeta.setValueBuffer("codcontacto",curContactos.valueBuffer("codcontacto"));
			curContactoTarjeta.setValueBuffer("codtarjeta",codigo);
			
			if (!curContactoTarjeta.commitBuffer())
				return false;
		}
		else {
			var curContactoCliente:FLSqlCursor = new FLSqlCursor("contactosclientes");
			curContactoCliente.setModeAccess(curContactoCliente.Insert);
			curContactoCliente.refreshBuffer();
			curContactoCliente.setValueBuffer("codcontacto",curContactos.valueBuffer("codcontacto"));
			curContactoCliente.setValueBuffer("codcliente",codigo);
			
			if (!curContactoCliente.commitBuffer())
				return false;
		}
	}
}

function oficial_deleteContacto(accion:String,codigo:String,codAsociado:String)
{
	var util:FLUtil;
	var f:Object;
	if (codigo) 
		f = new FLFormSearchDB("crm_editcontacto");
	else {
		codigo = this.child("tdbContactos").cursor().valueBuffer("codcontacto");
		codAsociado = this.cursor().valueBuffer("codCliente");
		if (sys.isLoadedModule("flcrm_ppal")){
			f = new FLFormSearchDB("crm_editcontacto");}
		else
			f = new FLFormSearchDB("editcontacto");
	}

	if (!codigo || codigo == "") {
		MessageBox.information(util.translate("scripts", "No hay ningún registro seleccionado."), MessageBox.Ok, MessageBox.NoButton);
		return;
	}

	var curContactos:FLSqlCursor = f.cursor(); 
	var preguntar:Boolean = false;
	if (accion == "crm_tarjetas") {
		if(util.sqlSelect("crm_contactostarjetas","codcontacto","codcontacto = '" + codigo + "' AND codtarjeta <> '" + codAsociado + "'") || util.sqlSelect("contactosclientes","codcontacto","1 = 1") || util.sqlSelect("contactosproveedores","codcontacto","1 = 1"))
			preguntar = true;		
	}
	else {
		if(util.sqlSelect("contactosclientes","codcontacto","codcontacto = '" + codigo + "' AND codcliente <> '" + codAsociado + "'") || util.sqlSelect("crm_contactostarjeta","codcontacto","1 = 1")) 
			preguntar = true;
	}
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

function oficial_deleteContactoAsociado(accion:String,codigo:String) 
{
	var util:FLUtil;
	var f:Object;

	if (accion == "crm_tarjetas")
		f = new FLFormSearchDB("crm_editcontactotarjeta");
	else {
		if(!codigo || codigo == "")
			codigo = this.child("tdbContactos").cursor().valueBuffer("codcontacto");
		f = new FLFormSearchDB("editcontactocliente");
	}

	var curContactos:FLSqlCursor = f.cursor();

	curContactos.select("codcontacto = '" + codigo + "'");
	if (!curContactos.first())
		return false;
	curContactos.setModeAccess(curContactos.Del);
	curContactos.refreshBuffer();
	var res:String;
	if (accion == "crm_tarjetas")
		res = MessageBox.information(util.translate("scripts", "Se va a desvincular el contacto seleccionado de la tarjeta. ¿Está seguro?"), MessageBox.Yes, MessageBox.No);
	else
		res = MessageBox.information(util.translate("scripts", "Se va a desvincular el contacto seleccionado del cliente. ¿Está seguro?"), MessageBox.Yes, MessageBox.No);

	if (res != MessageBox.Yes)
		return;

	curContactos.commitBuffer();
}

function oficial_insertContactoAsociado(accion:String,codAsociado:String) 
{
	if (this.cursor().modeAccess() == this.cursor().Insert) {
		if (!this.child("tdbDirecciones").cursor().commitBufferCursorRelation())
			return false;
	}
	
	var f:Object = new FLFormSearchDB("insertcontacto");;
	if (!codAsociado || codAsociado == "")
		codAsociado = this.cursor().valueBuffer("codcliente");

	f.setMainWidget();
	var codContacto:String = f.exec("codcontacto");
	if(!codContacto)
		return;

	if (f.accepted()) {
		if(accion == "crm_tarjetas") {
			var curContactoTarjeta:FLSqlCursor = new FLSqlCursor("crm_contactostarjeta");
			curContactoTarjeta.setModeAccess(curContactoTarjeta.Insert);
			curContactoTarjeta.refreshBuffer();
			curContactoTarjeta.setValueBuffer("codcontacto",codContacto);
			curContactoTarjeta.setValueBuffer("codtarjeta",codAsociado);
			
			if (!curContactoTarjeta.commitBuffer())
				return false;
		}
		else {
			var curContactoCliente:FLSqlCursor = new FLSqlCursor("contactosclientes");
			curContactoCliente.setModeAccess(curContactoCliente.Insert);
			curContactoCliente.refreshBuffer();
			curContactoCliente.setValueBuffer("codcontacto",codContacto);
			curContactoCliente.setValueBuffer("codcliente",codAsociado);
			
			if (!curContactoCliente.commitBuffer())
				return false;
		}
	}
}

function oficial_lanzarEdicionContacto()
{
	var util:FLUtil;
	var codContacto:String = this.child("fdbCodContacto").value();
	var accion:String = "";
	if (sys.isLoadedModule("flcrm_ppal"))
		accion = "crm_editcontacto";
	else
		accion = "editcontacto";

	var f:Object = new FLFormSearchDB(accion);
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
		var codCliente:String = this.cursor().valueBuffer("codcliente");

		if (!codCliente || codCliente == "")
			return;

// 		if(!this.iface.crearContactoTarjeta(codNuevoContacto,codTarjeta))
// 			return;

		var curCliCon:FLSqlCursor = new FLSqlCursor("contactosclientes");
		with(curCliCon) {
			setModeAccess(Insert);
			refreshBuffer();
			setValueBuffer("codcliente", codCliente);
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
	var codCliente:String = this.cursor().valueBuffer("codcliente");

	if(!codCliente)
		return;

	f.setMainWidget();
	f.cursor().setMainFilter("codcontacto IN(SELECT codcontacto FROM contactosclientes WHERE codcliente = '" + codCliente + "')");
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
