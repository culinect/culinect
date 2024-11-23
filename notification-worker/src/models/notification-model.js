export class NotificationModel {
    constructor(data) {
        this.id = data.id;
        this.userId = data.userId;
        this.title = data.title;
        this.body = data.body;
        this.type = data.type;
        this.data = data.data;
        this.createdAt = data.createdAt;
        this.isRead = data.isRead || false;
    }
}
