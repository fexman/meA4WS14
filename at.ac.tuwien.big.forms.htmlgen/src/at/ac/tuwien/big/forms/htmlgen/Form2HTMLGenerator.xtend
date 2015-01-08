package at.ac.tuwien.big.forms.htmlgen

import java.io.File
import at.ac.tuwien.big.forms.FormModel
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import at.ac.tuwien.big.forms.TextField
import at.ac.tuwien.big.forms.Page
import at.ac.tuwien.big.forms.RelationshipPageElement
import at.ac.tuwien.big.forms.CompositeCondition
import at.ac.tuwien.big.forms.PageElement
import at.ac.tuwien.big.forms.AttributeValueCondition
import org.eclipse.emf.ecore.EClass
import at.ac.tuwien.big.forms.AttributePageElement
import at.ac.tuwien.big.forms.TextArea
import at.ac.tuwien.big.forms.SelectionField
import at.ac.tuwien.big.forms.DateSelectionField
import at.ac.tuwien.big.forms.TimeSelectionField
import at.ac.tuwien.big.forms.Table
import at.ac.tuwien.big.forms.List

class Form2HTMLGenerator implements IGenerator {

	override doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		val listOfModels = resource.resourceSet.resources
		var formModel = null as FormModel
		for(model : listOfModels){
			if(model.contents.get(0) instanceof FormModel)
				formModel = model.contents.get(0) as FormModel
		}
		val name = new File('output.html');
		fsa.generateFile(
			name.toString,
			'''<!DOCTYPE html>
			<html lang="en">
					«generateHead(formModel)»
				<body>
					«generateBody(formModel)»
				</body>
			</html>'''	
		)
	}
	
	
			
	def generateHead(FormModel formModel) {
		'''<head>
	<title>Form</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
		<link rel="stylesheet" type="text/css" href="../assets/form.css"/>
		<script src="../assets/jquery-1.10.2.min.js" type="text/javascript"></script>
		<script src="../assets/form.js" type="text/javascript"></script>
		<script type="text/javascript">
		$(document).ready(
		function(){				 
		form.addWelcomeForm(' «formModel.forms.findFirst[element | element.welcomeForm].title»');
		«FOR form : formModel.forms»
			«FOR page : form.pages»
				«JSRegister(page)»
				«IF page.condition != null»
					«JSRegister(page.condition, page, null)»
				«ENDIF»
				«FOR pageElement : page.pageElements»
					«JSRegister(pageElement)»
					«IF pageElement.condition != null»
						«JSRegister(pageElement.condition, pageElement, null)»
					«ENDIF»
				«ENDFOR»
			«ENDFOR»
		«ENDFOR»
		form.init();
		});
		</script>
	</head>'''
	}
	
	def generateBody(FormModel formModel) {
		'''«FOR form : formModel.forms»
			<div class="form" id="«form.title»">
				<form action="#" class="register">
				<h1>«form.title»</h1>
				«IF !form.description.nullOrEmpty»
				<h2>«form.description»</h2>
				«ENDIF»
				«FOR page : form.pages»
					<div class="page" id="«page.title»">
						<fieldset class="row1">
							<h3>«page.title»</h3>
						 	«FOR pageElement : page.pageElements»
						 		«IF pageElement instanceof AttributePageElement»
						 		<p>
						 			<label for="«pageElement.elementID»">«pageElement.label»«IF pageElement.attribute.mandatory»<span>*</span>«ENDIF»</label>
						 			«IF pageElement instanceof TextField»				 					
						 				<input type="text" id="«pageElement.elementID»"«IF pageElement.attribute.mandatory» class="mandatory"«ENDIF»/>
						 			«ENDIF»
						 			«IF pageElement instanceof TextArea»
						 				<textarea id="«pageElement.elementID»"«IF pageElement.attribute.mandatory» class="mandatory"«ENDIF»></textarea>
						 			«ENDIF»
						 			«IF pageElement instanceof SelectionField»
						 				<select id="«pageElement.elementID»" name="«pageElement.attribute.name»"«IF pageElement.attribute.mandatory» class="mandatory"«ENDIF»>
						 					<option value="default"> </option>
						 				«IF pageElement.attribute.enumeration != null»
						 					«FOR literal : pageElement.attribute.enumeration.literals»
						 						<option value="«literal.name»">«literal.value»</option>
						 					«ENDFOR»
					 					«ELSE»
						 					<option value="Yes">Yes</option>
						 					<option value="No">No</option>
						 				«ENDIF»
						 				</select>
						 			«ENDIF»
						 			«IF pageElement instanceof DateSelectionField»
						 				<input type="date" id="«pageElement.elementID»"/>
						 			«ENDIF»
						 			«IF pageElement instanceof TimeSelectionField»
						 				<input type="time" id="«pageElement.elementID»"/>
						 			«ENDIF»
						 		</p>
						 		«ELSE»
						 			«IF pageElement instanceof List»
						 			<div class="list" id="«pageElement.elementID»">
						 				<fieldset class="row1">
						 					<legend class="legend">«pageElement.label» List</legend>
						 					<ul></ul>
						 				</fieldset>
						 			</div>
						 			«ENDIF»
						 			«IF pageElement instanceof Table»
						 			<div class="table" id="«pageElement.elementID»">
						 				<fieldset class="row1">
						 					<legend class="legend">«pageElement.label» Table</legend>
						 					<table>
						 				 		<tr id="«pageElement.elementID»_header">
								 				«FOR column : (pageElement as Table).columns»
								 				<th>«column.label»</th>
								 				«ENDFOR»
						 				 		</tr>
						 				 	</table>
						 				</fieldset>
						 			</div>
						 			«ENDIF»
						 		«ENDIF»
						 	«ENDFOR»
						 </fieldset>
					</div>
				«ENDFOR»
				</form>
			</div>
			«ENDFOR»'''
	}
	
	//
	// JavaScript-Regs
	//
	def dispatch JSRegister(Object o) {
		//Placeholder, do nothing
	}
	
	def dispatch JSRegister(TextField tf) {
		'''«IF tf.format != null»
				form.addRegularExpression('«tf.elementID»', '«tf.format»');
		«ENDIF»'''
	}
	
	def dispatch JSRegister(RelationshipPageElement pe) {
		'''form.addRelationshipPageElement('«(pe.eContainer as Page).title»', '«pe.elementID»', '«pe.editingForm.title»', '«pe.eClass.getName().toLowerCase()»', '«pe.relationship.lowerBound»', '«pe.relationship.upperBound»');'''
	}
	
	def dispatch JSRegister(CompositeCondition cc, Object o, String parent_id) {
		'''«IF parent_id != null»
			form.addCompositeCondition('«cc.conditionID»','«(cc.eContainer as CompositeCondition).conditionID»','«cc.compositionType»');
		«ELSE»
			form.addCompositeCondition('«cc.conditionID»',null,'«cc.compositionType»');
		«ENDIF»
		«JSRegister(cc.composedConditions.get(0),o,cc.conditionID)»
		«JSRegister(cc.composedConditions.get(1),o,cc.conditionID)»'''
	}
	
	def dispatch JSRegister(AttributeValueCondition ac, Object o, String parent_id) {
		'''«IF parent_id != null»
			form.addAttributeValueCondition('«ac.conditionID»',«(ac.eContainer as CompositeCondition).conditionID»,'«AVCContainer(o)»','«ac.value»','«ac.type»');
		«ELSE»
			form.addAttributeValueCondition('«ac.conditionID»',null,'«AVCContainer(o)»','«ac.value»','«ac.type»');
		«ENDIF»
		'''
	}
	
	def dispatch AVCContainer(Object o) {
		//Placeholder, do nothing
	}
	
	def dispatch AVCContainer(Page page) {
		'''«page.title»'''
	}
	
	def dispatch AVCContainer(PageElement pe) {
		'''«pe.elementID»'''
	}
}