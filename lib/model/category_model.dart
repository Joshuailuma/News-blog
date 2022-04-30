class CategoryModel {
  final String name, imageUrl;

  CategoryModel({required this.name, required this.imageUrl});
}

List<CategoryModel> categories = [
  CategoryModel(name: "Popular", imageUrl: "images/dog.jpg"),
  CategoryModel(name: "Politics", imageUrl: "images/dog.jpg"),
  CategoryModel(name: "Sports", imageUrl: "images/dog.jpg"),
  CategoryModel(name: "Tech", imageUrl: "images/dog.jpg"),
  CategoryModel(name: "Entertainment", imageUrl: "images/dog.jpg"),
];
