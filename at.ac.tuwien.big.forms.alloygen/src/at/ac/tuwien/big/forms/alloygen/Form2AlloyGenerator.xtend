package at.ac.tuwien.big.forms.alloygen

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import java.io.File
import at.ac.tuwien.big.forms.EntityModel
import at.ac.tuwien.big.forms.Entity
import at.ac.tuwien.big.forms.Relationship
import at.ac.tuwien.big.forms.Attribute
import at.ac.tuwien.big.forms.Enumeration

class Form2AlloyGenerator implements IGenerator {

	override doGenerate(Resource resource, IFileSystemAccess fsa) {

		var entityModel = resource.contents.get(0) as EntityModel
		var name = new File(resource.URI.toFileString).name.replace(".forms", ".als");

		fsa.generateFile(
			name,
			'''module ME14
				«FOR entityModelElement : entityModel.entityModelElements»
					«IF entityModelElement instanceof Entity»
						«var entity = entityModelElement as Entity»
						sig «entity.name» 
						«IF entity.superType != null»
							extends «entity.superType.name»
						«ENDIF»
						{
							«FOR feature : entity.features»
								«IF feature instanceof Attribute»
									«var attribute = feature as Attribute»
										«IF attribute.enumeration == null»
											«IF attribute.mandatory»
												«attribute.name» : one Int
											«ELSE»
												«attribute.name» : lone Int
											«ENDIF»
										«ELSE»
											enum : one «attribute.enumeration.name»
										«ENDIF»
										«««TODO comma
								«ENDIF»
								«IF feature instanceof Relationship»
									«var relationship = feature as Relationship»
										«IF relationship.lowerBound == 0 && relationship.upperBound == 1»
											«IF relationship.opposite != null»
												relationship : lone «relationship.opposite.name»
											«ELSE»
												relationship : lone «relationship.target.name»
											«ENDIF»
											
										«ENDIF»
										«IF relationship.lowerBound == 1 && relationship.upperBound == 1»
											«IF relationship.opposite != null»
												relationship : one «relationship.opposite.name»
											«ELSE»
												relationship : one «relationship.target.name»
											«ENDIF»
										«ENDIF»
										«IF relationship.lowerBound == 0 && relationship.upperBound == -1»
											«IF relationship.opposite != null»
												relationship : set «relationship.opposite.name»
											«ELSE»
												relationship : set «relationship.target.name»
											«ENDIF»
										«ENDIF»
										«IF relationship.lowerBound == 1 && relationship.upperBound == -1»
											«IF relationship.opposite != null»
												relationship : some «relationship.opposite.name»
											«ELSE»
												relationship : some «relationship.target.name»
											«ENDIF»
										«ENDIF»
								«ENDIF»
							«ENDFOR»
							
						}
					«ENDIF»
					
					«IF entityModelElement instanceof Enumeration»
						«var enum = entityModelElement as Enumeration»
						enum «enum.name» {
							«FOR literal : enum.literals»
								«literal.name»		
							«ENDFOR»
						}
					«ENDIF»
					
					
					
					
				«ENDFOR»
			'''
		)

	}

	def generateEntity(EntityModel entityModel) {
	}
}
