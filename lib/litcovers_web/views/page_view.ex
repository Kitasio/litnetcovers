defmodule LitcoversWeb.PageView do
  use LitcoversWeb, :view

  def showcase() do
    [
      %{
        img: "https://ik.imagekit.io/soulgenesis/litnet/showcase_1.jpg",
        heading: "Портреты",
        sub: "Вашего антогониста или протогониста произведения"
      },
      %{
        img: "https://ik.imagekit.io/soulgenesis/litnet/showcase_2.jpg",
        heading: "Миры",
        sub: "Удивительные по своей атмосфере и наполненности"
      },
      %{
        img: "https://ik.imagekit.io/soulgenesis/litnet/showcase_3.jpg",
        heading: "Атрибуты",
        sub: "Уникальные артефакты и предметы из ваших миров"
      }
    ]
  end

  def points do
    [
      %{
        icon: "https://ik.imagekit.io/soulgenesis/litnet/point_1.png",
        heading: "Передовые технологии и профессиональный штат",
        sub: "Ваша новая обложка — симбиоз нашего многолетнего опыта в сфере дизайна и технологий"
      },
      %{
        icon: "https://ik.imagekit.io/soulgenesis/litnet/point_2.png",
        heading: "Исходные файлы в высоком разрешении",
        sub:
          "Цифровые варианты и файлы под печать. Всё в одном месте, аккуратно сложенное для Вас"
      },
      %{
        icon: "https://ik.imagekit.io/soulgenesis/litnet/point_3.png",
        heading: "Быстрый результат и возможность выбора",
        sub: "Мы ценим Ваше время и точно знаем, что несколько вариантов  лучше, чем один"
      },
      %{
        icon: "https://ik.imagekit.io/soulgenesis/litnet/point_4.png",
        heading: "Простая и удобная система",
        sub: "Без мозгодробительного и непонятного. Просто попробуйте сами!"
      }
    ]
  end

  def covers do
    [
      "https://ik.imagekit.io/soulgenesis/litnet/cover_1.jpg",
      "https://ik.imagekit.io/soulgenesis/litnet/cover_2.jpg",
      "https://ik.imagekit.io/soulgenesis/litnet/cover_3.jpg",
      "https://ik.imagekit.io/soulgenesis/litnet/cover_4.jpg",
      "https://ik.imagekit.io/soulgenesis/litnet/cover_5.jpg",
      "https://ik.imagekit.io/soulgenesis/litnet/cover_6.jpg"
    ]
  end

  def current_year do
    DateTime.utc_now() |> Map.fetch!(:year)
  end
end
