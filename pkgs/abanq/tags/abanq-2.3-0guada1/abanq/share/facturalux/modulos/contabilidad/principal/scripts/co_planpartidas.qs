/***************************************************************************
                 co_planpartidas.qs  -  description
                             -------------------
    begin                : lun mar 27 2006
    copyright            : (C) 2006 by InfoSiAL S.L. y Guillermo Molleda Jimena
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
	function calculateCounter():Number { return this.ctx.interna_calculateCounter(); }
	function acceptedForm() { this.ctx.interna_acceptedForm(); }
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
	var longSubcuenta:Number;
	var ejercicioActual:String;
	var divisaEmpresa:String;
	var idCuentaEsp:Number;
	var bloqueo:Boolean;
	var bloqueoSubcuenta:Boolean;
	var permisoCP:Boolean;
	var esIVA:Boolean;
	var esDivisaExt:Boolean;
	var posActualPuntoSubcuenta:Number;
	var posActualPuntoContrapar:Number;
	
	function oficial( context ) { interna( context ); } 
	function cambioDH(debeOhaber) {
		return this.ctx.oficial_cambioDH(debeOhaber);
	}
	function habilitarIVA(siOno) {
		return this.ctx.oficial_habilitarIVA(siOno);
	}
	function desconexion() {
		return this.ctx.oficial_desconexion();
	}
	function bufferChanged(fN) {
		return this.ctx.oficial_bufferChanged(fN);
	}
	function controlDivisa() {
		return this.ctx.oficial_controlDivisa();
	}
	function controlIVA(noAnteriorDebeHaber) {
		return this.ctx.oficial_controlIVA(noAnteriorDebeHaber);
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
\end */
function interna_init()
{
	var util:FLUtil = new FLUtil();
	var cursor:FLSqlCursor = this.cursor();

	this.iface.ejercicioActual = flfactppal.iface.pub_ejercicioActual();
	this.iface.divisaEmpresa = util.sqlSelect("empresa", "coddivisa", "1 = 1");

	this.iface.longSubcuenta = util.sqlSelect("ejercicios", "longsubcuenta", "codejercicio = '" + this.iface.ejercicioActual + "'");
	this.iface.bloqueoSubcuenta = false;
	this.iface.posActualPuntoSubcuenta = -1;
	this.iface.posActualPuntoContrapar = -1;

	if (cursor.modeAccess() == cursor.Edit) {
		if (this.cursor().valueBuffer("debeohaber") == "Debe")
			this.child("chkDebe").setChecked(true);
		else
			this.child("chkHaber").setChecked(true);
		this.child("gbIva").setDisabled(true);
		this.iface.controlIVA(true);
	}

	if (cursor.modeAccess() == cursor.Insert) {
		this.child("fdbNumOrden").setValue(this.iface.calculateCounter());
		this.child("fdbCodDivisa").setValue(this.iface.divisaEmpresa);
		this.iface.habilitarIVA("no");
		this.iface.controlIVA();
		this.iface.cambioDH(0);
	}
	this.iface.bufferChanged("tsubcuenta");
	this.iface.bufferChanged("timporte");
	this.iface.bufferChanged("tconcepto");
	this.iface.bufferChanged("tdocumento");
	this.iface.bufferChanged("tcontrapartida");
	this.iface.bufferChanged("tbaseimponible");
	this.iface.bufferChanged("timporteme");
	this.iface.bufferChanged("coddivisa");

	connect(this.child("btgDH"), "clicked(int)", this, "iface.cambioDH");
	connect(cursor, "bufferChanged(QString)", this, "iface.bufferChanged");
	connect(this, "closed()", this, "iface.desconexion");
}

/** \D Calcula el número de orden de una prepartida nueva
\end */
function interna_calculateCounter():Number
{
	var util:FLUtil = new FLUtil();
	var numPrepartida:Number = util.sqlSelect("co_planpartidas", "MAX(numorden)","codplanasiento = '" + this.cursor().valueBuffer("codplanasiento") + "'");
	numPrepartida++;
	return numPrepartida;
}

function interna_acceptedForm()
{
	this.iface.desconexion();
}

//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////

function oficial_desconexion()
{
	disconnect(this.cursor(), "bufferChanged(QString)", this, "iface.bufferChanged");
	disconnect(this.child("btgDH"), "clicked(int)", this, "iface.cambioDH");
}

function oficial_bufferChanged(fN)
{
	var util:FLUtil = new FLUtil();

	switch(fN) {
		case "tsubcuenta":
			if (this.child("fdbTSubcuenta").value() == 0) {//"Establecer") {
				this.child("fdbCodSubcuenta").setDisabled(false);
				this.child("fdbNSubcuenta").setDisabled(false);
			}
			if (this.child("fdbTSubcuenta").value() == 1) {//"Pedir") {
				this.child("fdbCodSubcuenta").setDisabled(false);
				this.child("fdbNSubcuenta").setDisabled(false);
			}
			if (this.child("fdbTSubcuenta").value() == 2) {//"Definida") {
				this.child("fdbCodSubcuenta").setDisabled(true);
				this.child("fdbNSubcuenta").setDisabled(false);
			}
			break;

		case "timporte":
			if (this.child("fdbTImporte").value() == 1) {//"Calcular") {
				this.child("fdbImporte").setDisabled(false);
				this.child("fdbNImporte").setDisabled(true);
			}
			if (this.child("fdbTImporte").value() == 0) {//"Pedir") {
				this.child("fdbImporte").setDisabled(true);
				this.child("fdbNImporte").setDisabled(false);
			}
			if (this.child("fdbTImporte").value() == 2) {//"Cuadrar") {
				this.child("fdbImporte").setDisabled(true);
				this.child("fdbNImporte").setDisabled(true);
			}
			break;

		case "timporteme":
			if (this.child("fdbTImporteme").value() == 1) {//"Calcular") {
				this.child("fdbImporteme").setDisabled(false);
				this.child("fdbNImporteme").setDisabled(true);
			}
			if (this.child("fdbTImporteme").value() == 0) {//"Pedir") {
				this.child("fdbImporteme").setDisabled(true);
				this.child("fdbNImporteme").setDisabled(false);
			}
			if (this.child("fdbTImporteme").value() == 2) {//"Cuadrar") {
				this.child("fdbImporteme").setDisabled(true);
				this.child("fdbNImporteme").setDisabled(true);
			}
			break;

		case "tconcepto":
			if (this.child("fdbTConcepto").value() == 0) {//"Establecer") {
				this.child("fdbConcepto").setDisabled(false);
				this.child("fdbNConcepto").setDisabled(false);
			}
			if (this.child("fdbTConcepto").value() == 1) {//"Pedir") {
				this.child("fdbConcepto").setDisabled(false);
				this.child("fdbNConcepto").setDisabled(false);
			}
			if (this.child("fdbTConcepto").value() == 2) {//"Último") {
				this.child("fdbConcepto").setDisabled(true);
				this.child("fdbNConcepto").setDisabled(true);
			}
			if (this.child("fdbTConcepto").value() == 3) {//"Definido") {
				this.child("fdbConcepto").setDisabled(true);
				this.child("fdbNConcepto").setDisabled(false);
			}
			break;

		case "tdocumento":
			if (this.child("fdbTDocumento").value() == 0) {//"Establecer") {
				this.child("fdbDocumento").setDisabled(false);
				this.child("fdbTipoDocumento").setDisabled(false);
			}
			if (this.child("fdbTDocumento").value() == 1) {//"Pedir") {
				this.child("fdbDocumento").setDisabled(true);
				this.child("fdbTipoDocumento").setDisabled(true);
			}
			if (this.child("fdbTDocumento").value() == 2) {//"Último") {
				this.child("fdbDocumento").setDisabled(true);
				this.child("fdbTipoDocumento").setDisabled(true);
			}
			break;

		case "tbaseimponible":
			if (this.child("fdbTBaseImponible").value() == 1) {//"Calcular") {
				this.child("fdbBaseImponible").setDisabled(false);
				this.child("fdbNBaseImponible").setDisabled(true);
			}
			if (this.child("fdbTBaseImponible").value() == 0) {//"Pedir") {
				this.child("fdbBaseImponible").setDisabled(true);
				this.child("fdbNBaseImponible").setDisabled(false);
			}
			break;

		case "tcontrapartida":
			if (this.child("fdbTContrapartida").value() == 0) {//"Establecer") {
				this.child("fdbCodContrapartida").setDisabled(false);
				this.child("fdbNContrapartida").setDisabled(false);
			}
			if (this.child("fdbTContrapartida").value() == 1) {//"Pedir") {
				this.child("fdbCodContrapartida").setDisabled(false);
				this.child("fdbNContrapartida").setDisabled(false);
			}
			if (this.child("fdbTContrapartida").value() == 2) {//"Definida") {
				this.child("fdbCodContrapartida").setDisabled(true);
				this.child("fdbNContrapartida").setDisabled(false);
			}
			break;

		case "coddivisa":
			/** \C
			Al cambiar --coddivisa-- si la moneda no es la del sistema, habilita el cuadro Moneda extranjera
			\end */
				this.iface.controlDivisa();
			break;
		case "codsubcuenta":
			/** 
			\D
			Cuando alcanza el número de dígitos de la subcuenta, busca los datos asociados.
			\end */
			/** \C
			Al introducir --codsubcuenta--, si el usuario pulsa la tecla "punto" (.), la subcuenta se informa automaticamente con el código de cuenta más tantos ceros como sea necesario para completar la longitud de subcuenta asociada al ejercicio actual.
			\end */
				if (!this.iface.bloqueoSubcuenta) {
					this.iface.bloqueoSubcuenta = true;
					this.iface.posActualPuntoSubcuenta = flcontppal.iface.pub_formatearCodSubcta(this, "fdbCodSubcuenta", this.iface.longSubcuenta, this.iface.posActualPuntoSubcuenta);
					this.iface.bloqueoSubcuenta = false;
				}

			/** \C
			Si --codsubcuenta-- es de IVA se realizan las siguientes acciones: [1] se pone como divisa la divisa local y se deshabilita el campo de divisa (sólo se admite la divisa local), [2] se habilitan los campos de iva, se busca la utima partida insertada en el asiento presente y de ella se extrae el debe o haber, que se utiliza para informar el campo de base imponible.
			Si --codsubcuenta-- tiene asociada una divisa diferente de la divisa local, se inhabilitan los campos debe y haber principales y se habilitan los campos debe y haber de la divisa.
			\end */
				if (this.child("fdbCodSubcuenta").value().length == this.iface.longSubcuenta) {
					var q:FLSqlQuery = new FLSqlQuery();
					q.setTablesList("co_subcuentas");
					q.setSelect("coddivisa, iva");
					q.setFrom("co_subcuentas");
					q.setWhere("codsubcuenta = '" + this.child("fdbCodSubcuenta").value() + "' AND codejercicio = '" + this.iface.ejercicioActual + "'");
					q.exec();
					q.first();

					var divisaSubcuenta:String = q.value(0);
					var ivaSubcuenta:String = q.value(1);
					var idCuenta:Number = util.sqlSelect("co_subcuentas", "idcuenta", "codsubcuenta = '" + this.child("fdbCodSubcuenta").value() + "' AND codejercicio = '" + this.iface.ejercicioActual + "'");
					if (!idCuenta)
						return;

					if (divisaSubcuenta && divisaSubcuenta != this.iface.divisaEmpresa) {
						this.child("fdbCodDivisa").setValue(divisaSubcuenta);
						this.iface.esDivisaExt = true;
					} else {
						this.child("fdbCodDivisa").setValue(this.iface.divisaEmpresa);
						this.iface.esDivisaExt = false;
					}

					this.iface.idCuentaEsp = util.sqlSelect("co_cuentas", "idcuentaesp", "idcuenta= " + idCuenta);

					if (this.iface.idCuentaEsp == "IVASOP" || this.iface.idCuentaEsp == "IVAREP") {
							this.iface.esIVA = true;
							this.iface.habilitarIVA("si");
					} else {
							this.iface.esIVA = false;
							this.iface.habilitarIVA("no");
					}
				}
			break;

		case "codcontrapartida":
				/** \C 
				Al introducir --codcontrapartida--, se rellena con ceros el código de subcuenta de la contrapartida cuando el último carácter del código es un punto, al igual que en el código de subcuenta
				\end */
				if (!this.iface.bloqueoSubcuenta) {
					this.iface.bloqueoSubcuenta = true;
					this.iface.posActualPuntoContrapar = flcontppal.iface.pub_formatearCodSubcta(this, "fdbCodContrapartida", this.iface.longSubcuenta, this.iface.posActualPuntoContrapar);
					this.iface.bloqueoSubcuenta = false;
				}
			break;

	}
}

/** \D Se comprueba la divisa que está establecida y se compara con la divisa local. Si son iguales se inhabilitan y limpian los campos de debe y haber para divisa extranjera. Si son distintas se inhabilitan los campos debe y haber, que serán calculados según la tasa de conversión y los valores del debe y haber de divisa extranjera.
\end */
function oficial_controlDivisa()
{
	var cursor:FLSqlCursor = this.cursor();
	if (this.child("fdbCodDivisa").value() == this.iface.divisaEmpresa) {
		this.iface.esDivisaExt = false;
	} else {
		this.iface.esDivisaExt = true;
	}

	this.child("fdbTImporte").setDisabled(this.iface.esDivisaExt);
	this.child("fdbTImporteme").setDisabled(!(this.iface.esDivisaExt));
	if (this.iface.esDivisaExt == true) {
		this.child("fdbImporte").setDisabled(true);
		this.child("fdbNImporte").setDisabled(true);
		this.iface.bufferChanged("timporteme");
	}
	else {
		this.child("fdbImporteme").setDisabled(true);
		this.child("fdbNImporteme").setDisabled(true);
		this.iface.bufferChanged("timporte");
	}
}

/** \D Se comprueba si la cuenta de la que depende la subcuenta de la partida es una cuenta especial de iva soportado o repercutido. Si lo es, se habilita el marco I.V.A., si no lo es se inhabilita.

@param noAnteriorDebeHaber Indica si se calcula el anterior debe/haber
\end */
function oficial_controlIVA(noAnteriorDebeHaber)
{
	var util:FLUtil = new FLUtil();

	if (this.child("fdbCodSubcuenta").value().length == this.iface.longSubcuenta) {
		var q:FLSqlQuery = new FLSqlQuery();
		q.setTablesList("co_subcuentas");
		q.setSelect("coddivisa, iva");
		q.setFrom("co_subcuentas");
		q.setWhere("codsubcuenta = '" + this.child("fdbCodSubcuenta").value() + "' AND codejercicio = '" + this.iface.ejercicioActual + "'");

		if (!q.exec())
			return;

		if (!q.first())
			return;

		var divisaSubcuenta:String = q.value(0);
		var ivaSubcuenta:String = q.value(1);
		var idCuenta:Number = util.sqlSelect("co_subcuentas", "idcuenta", "codsubcuenta = '" + this.child("fdbCodSubcuenta").value() + "' AND codejercicio = '" +  this.iface.ejercicioActual + "'");
		if (!idCuenta)
			return;

		this.iface.idCuentaEsp = util.sqlSelect("co_cuentas", "idcuentaesp", "idcuenta= " + idCuenta);

		if (this.iface.idCuentaEsp == "IVASOP" || this.iface.idCuentaEsp == "IVAREP") {
			this.iface.esIVA = true;
			this.iface.habilitarIVA("si");
		} else {
			this.iface.esIVA = false;
			this.iface.habilitarIVA("no");
		}
	}
}

/** \D Devuelve el identificador del preasiento al que pertenece la prepartida
\end */
function oficial_obtenerIdPreAsiento():Number
{
	var util:FLUtil = new FLUtil();
	var res:Number = util.sqlSelect("co_planasientos", "idpreasiento", "numero = " + this.child("fdbAsiento").value());
	res = this.cursor().valueBuffer("idPreAsiento");
	return res;
}

/** D Habilita los controles de IVA o los inhabilita y pone a cero.

@param	siOno Toma los valores 'si' para habilitar o 'no' para deshabilitar las opciones de I.V.A.
\end */
function oficial_habilitarIVA(siOno)
{
	switch(siOno) {
		case "si":
			this.child("gbIva").setDisabled(false);
			this.child("fdbCodDivisa").setValue(this.iface.divisaEmpresa);
			this.child("gbDivisa").setDisabled(true);
			
			break;
				
		case "no":
			this.child("gbIva").setDisabled(true);
			this.child("gbDivisa").setDisabled(false);

			break;
	}
}

/** \D Intercambia los valores de --debe-- y --haber-- en una partida de IVA

@param debeOhaber Es el valor que devuelve el cuadro de botones de radio del formulario: 0 para el debe y 1 para el haber
\end */
function oficial_cambioDH(debeOhaber)
{
	if (debeOhaber == 0) {
		this.cursor().setValueBuffer("debeohaber", "Debe");
	} else {
		this.cursor().setValueBuffer("debeohaber", "Haber");
	}
}

//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
