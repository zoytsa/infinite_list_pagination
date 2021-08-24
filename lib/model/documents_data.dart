import 'dart:convert';

ListOfDocuments listOfDocumentsFromJson(String str) =>
    ListOfDocuments.fromJson(json.decode(str));

String listOfDocumentsToJson(ListOfDocuments data) =>
    json.encode(data.toJson());

class ListOfDocuments {
  String lastElementId = '';
  String lastElementTitle = '';
  String firstElementId = '';
  String firstElementTitle = '';
  String isOffsetPagination = 'false';
  String objectType = 'documents-task';
  String sessionId = '';
  String filter = '';
  int size = 25;
  String useCache = 'false';
  List<DocumentInfo> data = [];
  int totalElements = 0;
  int totalPages = 0;
  String maxElementId = "";

  ListOfDocuments(
      {required this.lastElementId,
      required this.lastElementTitle,
      required this.firstElementId,
      required this.firstElementTitle,
      required this.isOffsetPagination,
      required this.objectType,
      required this.sessionId,
      required this.filter,
      required this.size,
      required this.useCache,
      required this.totalElements,
      required this.totalPages,
      required this.maxElementId,
      required this.data});

  ListOfDocuments.fromJson(Map<String, dynamic> json) {
    lastElementId = json['last_element_id'];
    lastElementTitle = json['last_element_title'];
    firstElementId = json['first_element_id'];
    firstElementTitle = json['first_element_title'];
    isOffsetPagination = json['is_offset_pagination'];
    objectType = json['object_type'];
    sessionId = json['session_id'];
    filter = json['filter'];
    size = json['size'];
    totalElements = json['total_elements'];
    totalPages = json['total_pages'];
    useCache = json['use_cache'];
    maxElementId = json['max_element_id'];

    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(new DocumentInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> DocumentInfo = new Map<String, dynamic>();
    DocumentInfo['last_element_id'] = this.lastElementId;
    DocumentInfo['last_element_title'] = this.lastElementTitle;
    DocumentInfo['first_element_id'] = this.firstElementId;
    DocumentInfo['first_element_title'] = this.firstElementTitle;
    DocumentInfo['is_offset_pagination'] = this.isOffsetPagination;
    DocumentInfo['object_type'] = this.objectType;
    DocumentInfo['session_id'] = this.sessionId;
    DocumentInfo['filter'] = this.filter;
    DocumentInfo['size'] = this.size;
    DocumentInfo['use_cache'] = this.useCache;
    DocumentInfo['total_elements'] = this.totalElements;
    DocumentInfo['total_pages'] = this.totalPages;
    DocumentInfo['max_element_id'] = this.maxElementId;
    if (this.data != null) {
      DocumentInfo['DocumentInfo'] = this.data.map((v) => v.toJson()).toList();
    }
    return DocumentInfo;
  }
}

class DocumentInfo {
  String id = '';
  String createdDate = '';
  String editedDate = '';
  int operationId = 1;
  int productsCount = 0;
  String number = '';
  String date = '';

  DocumentInfo(
      {required this.id,
      required this.createdDate,
      required this.editedDate,
      required this.operationId,
      required this.productsCount,
      required this.number,
      required this.date});

  DocumentInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdDate = json['created_date'];
    editedDate = json['edited_date'];
    operationId = json['operation_id'];
    productsCount = json['products_count'];
    number = json['number'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> DocumentInfo = new Map<String, dynamic>();
    DocumentInfo['id'] = this.id;
    DocumentInfo['created_date'] = this.createdDate;
    DocumentInfo['edited_date'] = this.editedDate;
    DocumentInfo['operation_id'] = this.operationId;
    DocumentInfo['products_count'] = this.productsCount;
    DocumentInfo['number'] = this.number;
    DocumentInfo['date'] = this.date;
    return DocumentInfo;
  }
}
