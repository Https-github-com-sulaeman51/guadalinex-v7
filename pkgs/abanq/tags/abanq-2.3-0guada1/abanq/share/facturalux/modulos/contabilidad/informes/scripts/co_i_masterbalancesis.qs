/***************************************************************************
                 i_masterbalancesis.qs  -  description
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
    function oficial( context ) { interna( context ); } 
		function lanzar() {
				return this.ctx.oficial_lanzar();
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

/** \C El botón de impresión lanza el informe
\end */
function interna_init()
{ 
		connect(this.child("toolButtonPrint"), "clicked()", this, "iface.lanzar()");
}
//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
/** \D Lanza el informe 

Se hacen algunas modificacione sobre la consulta del informe:

Se añade un GROUP BY para calcular la suma de saldos de las subcuentas agrupadas por cuenta. Si se marca la opción de consolidar ejercicio, se añaden al WHERE de la consulta los datos del ejercicio anterior para que también sean sumados en el informe resultante.
\end */
function oficial_lanzar()
{
		var util:FLUtil = new FLUtil;
		var cursor:FLSqlCursor = this.cursor()
		if (!cursor.isValid())
				return;

		var asientoPyG:String;
		var asientoPyGAnt:String;
		var asientoCierre:String;
		var asientoCierreAnt:String;

		var nombreInforme:String = cursor.action();

		var groupBy:String = "empresa.nombre, co_cuentas.idcuenta, co_cuentas.codcuenta," +
			"co_cuentas.descripcion, co_subcuentas.idsubcuenta, co_subcuentas.codsubcuenta,"
			+ "co_subcuentas.descripcion, co_subcuentas.codcuenta";

		var masWhere:String = "";
		if (cursor.valueBuffer("ignorarcierre")) {
			asientoPyG = util.sqlSelect("ejercicios", "idasientopyg", "codejercicio = '" + cursor.valueBuffer("i_co__subcuentas_codejercicio") + "'");
			if (!asientoPyG)
				asientoPyG = -1;

			asientoCierre = util.sqlSelect("ejercicios", "idasientocierre", "codejercicio = '" + cursor.valueBuffer("i_co__subcuentas_codejercicio") + "'");
			if (!asientoCierre)
				asientoCierre = -1;
		
			masWhere = " AND co_asientos.idasiento NOT IN (" + asientoPyG + ", "	+ asientoCierre + ")";
		}
		

		var consolidar:Boolean = false;
		if (cursor.valueBuffer("ejercicioanterior") == 1)
				consolidar = true;

		if (consolidar) {
			var ejAnt:String = cursor.valueBuffer("codejercicioant");
			var desdeAnt:String = cursor.valueBuffer("fechaant_d");
			var hastaAnt:String = cursor.valueBuffer("fechaant_h");
			var desdeScta:String = cursor.valueBuffer("d_co__subcuentas_codsubcuenta");
			var hastaScta:String = cursor.valueBuffer("h_co__subcuentas_codsubcuenta");
				
			masWhere +=  " OR (co_asientos.codejercicio = '" + ejAnt + "'" +
				" AND co_asientos.fecha >= '" + desdeAnt + "'" +
				" AND co_asientos.fecha <= '" + hastaAnt + "'" +
				" AND co_partidas.codsubcuenta >= '" + desdeScta + "'" +
				" AND co_partidas.codsubcuenta <= '" + hastaScta + "'";
			
			if (cursor.valueBuffer("ignorarcierre")) {
				asientoPyGAnt = util.sqlSelect("ejercicios", "idasientopyg", "codejercicio = '" + ejAnt + "'");
				if (!asientoPyGAnt)
					asientoPyGAnt = -1;
	
				asientoCierreAnt = util.sqlSelect("ejercicios", "idasientocierre", "codejercicio = '" + ejAnt + "'");
				if (!asientoCierreAnt)
					asientoCierreAnt = -1;
			
				masWhere += " AND co_asientos.idasiento NOT IN (" + asientoPyGAnt + ", "	+ asientoCierreAnt + ")";
			}
			masWhere += ")";
		}
		
		var nombreReport:String = nombreInforme;
		if ( cursor.valueBuffer("nivel") == "Cuenta")
			nombreReport = "co_i_balancesis_res";
		
		flcontinfo.iface.pub_lanzarInforme(cursor, nombreInforme, nombreReport, "", groupBy, masWhere, cursor.valueBuffer("id"));
}

//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
