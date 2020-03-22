## Zones

resource "aws_route53_zone" "fanout-us" {
  name = "fanout.us"
}

resource "aws_route53_zone" "fanout-int" {
    name = "int-fanout.shop"
    vpc {
        vpc_id = aws_vpc.main.id
    }
} 

resource "aws_route53_zone" "fanout-shop" {
    name = "fanout.shop"
}
## Fanout.shop Records

resource "aws_route53_record" "shop-main" {
    zone_id = aws_route53_zone.fanout-shop.zone_id
    name = "fanout.shop"
    type = "A"
    ttl = "30"
    records = [aws_instance.wp.public_ip]
}

resource "aws_route53_record" "shop-mx" {
    zone_id = aws_route53_zone.fanout-shop.zone_id
    name    = "fanout.shop"
    type    = "MX"
    ttl     = "30"
    records = [
        "1 ASPMX.L.GOOGLE.COM.",
        "5 ALT1.ASPMX.L.GOOGLE.COM.",
        "5 ALT2.ASPMX.L.GOOGLE.COM.",
        "10 ASPMX2.GOOGLEMAIL.COM.",
        "10 ASPMX3.GOOGLEMAIL.COM."
    ]
}

resource "aws_route53_record" "shop-txt" {
    zone_id = aws_route53_zone.fanout-shop.zone_id
    name    = "fanout.shop"
    type    = "TXT"
    ttl     = "30"
    records = [
        "facebook-domain-verification=ycou0zzqpuvg5z36uf0n6mt7exyulp",
        "google-site-verification=g_yhhg3_JXb5N3DYugwnh8mW98Mj6qb2oeV6syv80Tg",
        "v=spf1 include:servers.mcsv.net ?all"
    ]
}

resource "aws_route53_record" "shop-acm" {
    zone_id = aws_route53_zone.fanout-shop.zone_id
    name = "_0d21f7e3321d3ef78e967e91dd4d0d72"
    type = "CNAME"
    ttl = "30"
    records = ["TBD"]
}

resource "aws_route53_record" "shop-dkim" {
    zone_id = aws_route53_zone.fanout-shop.zone_id
    name = "k1._domainkey"
    type = "CNAME"
    ttl = "30"
    records = ["dkim.mcsv.net"]
}

resource "aws_route53_record" "bastion" {
    zone_id = aws_route53_zone.fanout-shop.zone_id
    name = "bastion"
    type = "A"
    ttl = "30"
    records = [aws_instance.bastion.public_ip]
}


# ## Fanout.us Records

resource "aws_route53_record" "us-main" {
    zone_id = aws_route53_zone.fanout-us.zone_id
    name = "fanout.us"
    type = "A"
    ttl = "30"
    records = [aws_instance.wp.public_ip]
}

resource "aws_route53_record" "us-mx" {
    zone_id = aws_route53_zone.fanout-us.zone_id
    name    = "fanout.us"
    type    = "MX"
    ttl     = "30"
    records = [
        "1 ASPMX.L.GOOGLE.COM.",
        "5 ALT1.ASPMX.L.GOOGLE.COM.",
        "5 ALT2.ASPMX.L.GOOGLE.COM.",
        "10 ASPMX2.GOOGLEMAIL.COM.",
        "10 ASPMX3.GOOGLEMAIL.COM."
    ]
}

resource "aws_route53_record" "us-txt" {
    zone_id = aws_route53_zone.fanout-shop.zone_id
    name    = "fanout.us"
    type    = "TXT"
    ttl     = "30"
    records = [
        "google-site-verification=HbfxoBZ2H86DKtqWVnwDU8WUWimqtsCwmyeJsSplRp8",
        "facebook-domain-verification=1ywdedzxo49o6ejlbu73j2pz8rgsy4"
    ]
}

# ## Fanout Internal Records

resource "aws_route53_record" "int-db" {
    zone_id = aws_route53_zone.fanout-int.zone_id
    name = "db"
    type = "A"
    ttl = "30"
    records = [aws_instance.db.private_ip]
}

resource "aws_route53_record" "int-wp" {
    zone_id = aws_route53_zone.fanout-int.zone_id
    name = "wp"
    type = "A"
    ttl = "30"
    records = [aws_instance.wp.private_ip]
}

