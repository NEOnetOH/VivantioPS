using System;

namespace Vivantio
{
  public class TicketUpdateRequest
    {
        public ulong ClientId { get; set;}
        public ulong LocationId { get; set; }
        public ulong CallerId { get; set; }
        public string CallerName { get; set; }
        public string CallerEmail { get; set; }
        public string CallerPhone { get; set; }
        public string OpenDate { get; set; }
        public ulong TakenById { get; set; }
        public ulong ImpactId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string DescriptionHtml { get; set; }
        public string CCAddressList { get; set; }
        public ulong AffectedTickets { get; set; }
        public string Effort { get; set; }

        // Implicit Constructor.
        public TicketUpdateRequest() { }

        // Explicit constructor.
        public TicketUpdateRequest(ulong clientId, ulong locationId, ulong callerId, string callerName, string callerEmail, string callerPhone, string openDate, ulong takenById, ulong impactId, string title, string description, string descriptionHtml, string ccAddressList, ulong affectedTickets, string effort)
        {
            this.ClientId = clientId;
            this.LocationId = locationId;
            this.CallerId = callerId;
            this.CallerName = callerName;
            this.CallerEmail = callerEmail;
            this.CallerPhone = callerPhone;
            this.OpenDate = openDate;
            this.TakenById = takenById;
            this.ImpactId = impactId;
            this.Title = title;
            this.Description = description;
            this.DescriptionHtml = descriptionHtml;
            this.CCAddressList = ccAddressList;
            this.AffectedTickets = affectedTickets;
            this.Effort = effort;
        }
    }
}