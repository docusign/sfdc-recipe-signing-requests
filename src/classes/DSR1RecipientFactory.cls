public class DSR1RecipientFactory {

    public static DocuSignTK.Recipient makeRecipientFromUser(User user) {
        DocuSignTK.Recipient recipient = new DocuSignTK.Recipient();
        recipient.Email = user.Email;
        recipient.UserName = user.FirstName + ' ' + user.LastName;
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.CaptiveInfo = new DocuSignTK.RecipientCaptiveInfo();
        recipient.CaptiveInfo.ClientUserID = user.Id;
        return recipient;
    }
          
}