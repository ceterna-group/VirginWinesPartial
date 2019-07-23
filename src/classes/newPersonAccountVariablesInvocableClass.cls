/**
 * Created by lferreira036 on 17-06-2019.
 */
public class newPersonAccountVariablesInvocableClass {
	public class FlowInputs{
		@InvocableVariable
		public String firstName;

		@InvocableVariable
		public String lastName;

		@InvocableVariable
		public String salutation;

		@InvocableVariable
		public String emailAddress;

		@InvocableVariable
		public Date DateOfBirth;

		@InvocableVariable
		public String store;

		@InvocableVariable
		public String tel1;

		@InvocableVariable
		public String tel2;

		@InvocableVariable
		public String tel3;

		@InvocableVariable
		public Boolean AllowMarketingCommunications;
	}

	// "FlowOutputs" wrapper class
	// @InvocableVariables to store outputs from Apex to Flow
	public class FlowOutputs{
		@InvocableVariable
		public String firstName;

		@InvocableVariable
		public String lastName;

		@InvocableVariable
		public String salutation;

		@InvocableVariable
		public String emailAddress;

		@InvocableVariable
		public Date DateOfBirth;

		@InvocableVariable
		public String store;

		@InvocableVariable
		public String tel1;

		@InvocableVariable
		public String tel2;

		@InvocableVariable
		public String tel3;

		@InvocableVariable
		public Boolean AllowMarketingCommunications;
	}

	@InvocableMethod(label='Invoke Apex method: New Person Account' description='Create a Person Account in Mantiki, if succeds create in Salesforce')
	public static List<FlowOutputs> newPersonAccount(List<FlowInputs>  flowInputs) {
		List<FlowOutputs> flowOutputsList = new List<FlowOutputs>();
		FlowOutputs flowOutputs = new FlowOutputs();

		flowOutputs.store = flowInputs[0].store;
		flowOutputs.salutation = flowInputs[0].salutation;
		flowOutputs.firstName = flowInputs[0].firstName;
		flowOutputs.lastName = flowInputs[0].lastName;
		flowOutputs.emailAddress = flowInputs[0].emailAddress;
		flowOutputs.DateOfBirth = flowInputs[0].DateOfBirth;
		flowOutputs.tel1 = flowInputs[0].tel1;
		flowOutputs.tel2 = flowInputs[0].tel2;
		flowOutputs.tel3 = flowInputs[0].tel3;
		flowOutputs.AllowMarketingCommunications = flowInputs[0].AllowMarketingCommunications;
		flowOutputsList.add(flowOutputs);

		return flowOutputsList;
	}
}