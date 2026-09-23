import 'package:flutter/material.dart';

import '../models/category.dart';

const categoryCore = 'core';
const categoryPeople = 'people';
const categoryFood = 'food';
const categoryEmotions = 'emotions';
const categoryPlaces = 'places';
const categoryActivities = 'activities';
const categoryObjects = 'objects';
const categoryFavorites = 'favorites';

const mockCategories = <CaaCategory>[
  CaaCategory(
    id: categoryCore,
    name: 'Esenciales',
    description: 'Vocabulario base y de alta frecuencia',
    icon: Icons.grid_view_outlined,
    color: Color(0xFF2B7A78),
    position: 1,
  ),
  CaaCategory(
    id: categoryPeople,
    name: 'Personas',
    description: 'Familia, amigos y cuidadores',
    icon: Icons.people_alt_outlined,
    color: Color(0xFF6C63FF),
    position: 2,
    imagePath: 'assets/categories/personas.png',
  ),
  CaaCategory(
    id: categoryFood,
    name: 'Comida',
    description: 'Alimentos, bebidas y acciones',
    icon: Icons.restaurant_outlined,
    color: Color(0xFFE76F51),
    position: 3,
    imagePath: 'assets/categories/comida.png',
  ),
  CaaCategory(
    id: categoryEmotions,
    name: 'Emociones',
    description: 'Estados de ánimo y sensaciones',
    icon: Icons.sentiment_satisfied_alt_outlined,
    color: Color(0xFFE9C46A),
    position: 4,
    imagePath: 'assets/categories/emociones.png',
  ),
  CaaCategory(
    id: categoryPlaces,
    name: 'Lugares',
    description: 'Sitios cotidianos e importantes',
    icon: Icons.place_outlined,
    color: Color(0xFF457B9D),
    position: 5,
    imagePath: 'assets/categories/lugares.png',
  ),
  CaaCategory(
    id: categoryActivities,
    name: 'Actividades',
    description: 'Acciones, juegos y rutinas',
    icon: Icons.sports_esports_outlined,
    color: Color(0xFF2A9D8F),
    position: 6,
    imagePath: 'assets/categories/actividad.png',
  ),
  CaaCategory(
    id: categoryObjects,
    name: 'Objetos',
    description: 'Pictogramas personalizados de objetos',
    icon: Icons.inventory_2_outlined,
    color: Color(0xFF8D6E63),
    position: 7,
    imagePath: 'assets/categories/objeto.png',
  ),
  CaaCategory(
    id: categoryFavorites,
    name: 'Favoritos',
    description: 'Acceso rapido a palabras frecuentes',
    icon: Icons.star_border_rounded,
    color: Color(0xFFFFB703),
    position: 8,
    isFilter: true,
    imagePath: 'assets/categories/favorito.png',
  ),
];

List<CaaCategory> editableCategories() {
  return mockCategories.where((category) => !category.isFilter).toList();
}

CaaCategory categoryById(String id) {
  return mockCategories.firstWhere(
    (category) => category.id == id,
    orElse: () => mockCategories.first,
  );
}
