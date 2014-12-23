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
«««					add HTML elements here
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
				form.addWelcomeForm('«formModel.forms.findFirst[element | element.welcomeForm].title»');
				«FOR form : formModel.forms»
					«FOR page : form.pages»
						«JSRegister(page)»
						«IF page.condition != null»
							«JSRegister(page.condition)»
						«ENDIF»
						«FOR pageElement : page.pageElements»
							«JSRegister(pageElement)»
							«IF pageElement.condition != null»
								«JSRegister(pageElement.condition)»
							«ENDIF»
						«ENDFOR»
					«ENDFOR»
				«ENDFOR»
				form.init();
				});
				</script>
			</head>'''
	}
	
	//
	// JavaScript-Regs
	//
	def dispatch JSRegister(Object o) {
		//Placeholder, do nothing
	}
	
	def dispatch JSRegister(TextField tf) {
		'''«IF tf.format != null»
				form.addRegularExpression('«tf.elementID»','«tf.format»');
		«ENDIF»'''
	}
	
	def dispatch JSRegister(RelationshipPageElement pe) {
		'''form.addRelationshipPageElement('«(pe.eContainer as Page).title»','«pe.elementID»','«pe.editingForm.title»','«pe.eClass.getName().toLowerCase()»','«pe.relationship.lowerBound»','«pe.relationship.upperBound»');'''
	}
	
	def dispatch JSRegister(CompositeCondition cc) {
		'''«IF cc.eContainer instanceof CompositeCondition»
			form.addCompositeCondition('«cc.conditionID»','«(cc.eContainer as CompositeCondition).conditionID»','«cc.compositionType»');'
		«ELSE»
			form.addCompositeCondition('«cc.conditionID»',null,'«cc.compositionType»');'
		«ENDIF»
		'''
	}
	
	def dispatch JSRegister(AttributeValueCondition ac) {
		//TODO
	}
	
}