public with sharing class ContentRepo extends BaseRepo {
    public ContentRepo() {
        super(ContentVersion.SObjectType, true);
    }

    /* Create a new content version. */
    public Database.SaveResult createContentVersion(Blob versionData) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData = versionData;
        contentVersion.ContentLocation = 'S';
        contentVersion.Title = 'Tracking_Response_' + System.now().format('yyyy-MM-dd_HH-mm-ss') + '.json';
        contentVersion.PathOnClient = contentVersion.Title;
        contentVersion.IsMajorVersion = true;
        contentVersion.Origin = 'C';

        return doCreate(contentVersion);
    }

    /* Fetch the content version body by id. */
    public String fetchContentVersionBodyById(Id contentVersionId) {
        ContentVersion contentVersion = (ContentVersion) fetchById(contentVersionId, new Set<String>{ 'VersionData' });
        return contentVersion.VersionData.toString();
    }

    /* Fetch content versions by id. */
    public Map<Id, String> fetchContentVersionsById(List<Id> contentVersionIds) {
        Map<Id, String> contentVersionMap = new Map<Id, String>();
        List<ContentVersion> contentVersions = this.fetch(
            'SELECT Id, VersionData FROM ContentVersion WHERE Id IN :contentVersionIds',
            new Map<String, Object>{ 'contentVersionIds' => contentVersionIds }
        );
        for (ContentVersion contentVersion : contentVersions) {
            contentVersionMap.put(contentVersion.Id, contentVersion.VersionData.toString());
        }
        return contentVersionMap;
    }
}
