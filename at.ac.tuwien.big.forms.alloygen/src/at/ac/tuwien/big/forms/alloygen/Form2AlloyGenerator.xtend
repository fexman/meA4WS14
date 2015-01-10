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
import java.util.ArrayList

class Form2AlloyGenerator implements IGenerator {

	var list = new ArrayList<Relationship>();

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
											«IF attribute.mandatory»
												«attribute.name» : one «attribute.enumeration.name»
											«ELSE»
												«attribute.name» : lone «attribute.enumeration.name»
											«ENDIF»
										«ENDIF»
								«ENDIF»
								«IF feature instanceof Relationship»
									«var relationship = feature as Relationship»
									 «relationship.name» : 
									 	«IF multiplicity(relationship.lowerBound, relationship.upperBound) != null»
									 		«multiplicity(relationship.lowerBound, relationship.upperBound)» «relationship.target.name»
									 	«ELSE»
									 		set «relationship.target.name» 
									 		«addToList(relationship)»
									 	«ENDIF»
								«ENDIF»
								«IF !entity.features.last.equals(feature)»
									,
								«ENDIF»
							«ENDFOR»
							
						}
					«ENDIF»
					
					«IF entityModelElement instanceof Enumeration»
						«var enum = entityModelElement as Enumeration»
						enum «enum.name» {
							«FOR literal : enum.literals»
								«literal.name»
								«IF !enum.literals.last.equals(literal)»	
									,
								«ENDIF»
							«ENDFOR»
						}
					«ENDIF»
					
					
					
					
				«ENDFOR»
				«IF name.equals("courseEntityModel")»
					«createMultiplicityFact()»
				«ENDIF»
			'''
		)

	}

	def String multiplicity(int lower, int upper) {
		if(lower == 0 && upper == 1) return "lone";
		if(lower == 1 && upper == 1) return "one";
		if(lower == 0 && upper == -1) return "set";
		if(lower == 1 && upper == -1) return "some";

		//all others
		return null;
	}

	def String addToList(Relationship rel) {
		this.list.add(rel);
		return "";
	}

	def String createMultiplicityFact() {
		return '''
			fact {
			«FOR rel : this.list»
				( all z : «rel.opposite.target.name» | #z.«rel.name» >= «rel.lowerBound» ) and
			«ENDFOR»
			(all x:Student | all y:Course | y in x.likes implies x in y.isLikedBy) and 
			(all x:Student | all y:Course | y in x.enrols implies x in y.isEnroledBy) and 
			(all x:Course | all y:Student | y in x.isEnroledBy implies x in y.enrols) and 
			(all x:Course | all y:Student | y in x.isLikedBy implies x in y.likes)
				}
		'''
	}

//	def Boolean checkOpposite(Relationship rel) {
//		var opposite = rel.opposite;
//		var isOpposite = false;
//		for (feature : rel.target.features) {
//			if (feature instanceof Relationship) {
//				var relationship = feature as Relationship;
//				if (opposite.equals(relationship)) {
//					isOpposite = true;
//				}
//			}
//
//		};
//		return isOpposite;
//	}
}
