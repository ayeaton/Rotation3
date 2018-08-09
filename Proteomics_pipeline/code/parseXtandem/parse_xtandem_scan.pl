#!c:/perl/bin/perl.exe
#

use strict;

my $error=0;
my $dir=0;
my $threshold=0;
my $proton_mass=1.007276;
if ($ARGV[0]=~/\w/) { $dir=$ARGV[0];} else { $dir="."; }
if ($ARGV[1]=~/\w/) { $threshold=$ARGV[1];} else { $threshold=1e-1; }
if ($error==0)
{
	my $line="";
	if (opendir(dir,"$dir"))
	{
		my @allfiles=readdir dir;
		closedir dir;
		my $filename_count=0;
		foreach my $filename (@allfiles)
		{
			if ($filename=~/\.xml$/i and $filename!~/_input\.xml$/i)
			{
				if (open (IN,qq!$dir/$filename!))
				{
					if (open (OUT,qq!>$dir/$filename.txt!))
					{
						print OUT qq!peptide\tmodifications\tcharge\texpect\tscan\tintensity\tproteins\n!;
						my $protein="";
						my $proteins="";
						my $scan="";
						my $start="";
						my $expect="";
						my $intensity="";
						my $peptide="";
						my $modifications="";
						my $reversed=0;
						while ($line=<IN>)
						{
							chomp($line);
							if ($line=~/sumI="([^\"]+)"\s+maxI/)
							{
								$intensity=$1;
								if ($intensity=~/\w/)
								{
									$intensity=10**$intensity;
								}
							}
							if ($line=~/^\<protein\s+.*expect="([^\"]+)"\s+.*label="([^\"]+)"/)
							{
								$protein=$2;
								if($protein=~/\:reversed$/) { $reversed=1; }
								else
								{
									$protein=~s/\s.*$//;
									if ($protein=~/^sp/) { $protein=~s/\|/_/g; }
									if ($proteins!~/#$protein#/) { $proteins.="#$protein#"; }
									#if ($protein=~/^sp/) { print "$protein $proteins\n"; }
								}
							}
							if ($line=~/\<domain\s+id="([0-9\.edED\+\-]+)".*start="([0-9]+)".*end="([0-9]+)".*expect="([0-9\.edED\+\-]+)".*mh="([0-9\.edED\+\-]+)".*delta="([0-9\.edED\+\-]+)".*pre="(.*)".*post="(.*)".*seq="([A-Z]+)".*missed_cleavages="([0-9]+)"/)
							{
								$start=$2;
								$expect=$4;
								$peptide=$9;
								$modifications="";
								if ($line!~/\<domain[^\>]+\/\>/)
								{
									while ($line!~/\<\/domain\>/)
									{
										$line=<IN>;
										while($line=~s/^\s*\<aa\s+type=\"([A-Z])\"\s+at=\"([0-9]+)\"\s+modified=\"([0-9\.\-\+edED]+)\"\s*//)
										{
											my $mod_aa=$1;
											my $mod_pos=$2-$start+1;
											my $mod_mass=$3;
											my $mod_pm="";
											my $mod_id="";
											if ($line=~s/^\s*pm=\"([A-Z])\"\s*id="([^\"]+)"\s*//)
											{
												$mod_pm=$1;
												$mod_id=$2;
											}
											$modifications.="$mod_mass\@$mod_aa$mod_pos";
											if ($mod_pm=~/\w/){ $modifications.="->$mod_pm"; }
											$modifications.=",";
											$line=~s/^\s*\/\>\s*//;
										}
									}
								}
							}
							if($line=~/\<note label="Description"\>Scan ([0-9]+)\,*/)	
							{
								$scan=$1;
							} elsif ($line=~/\<note label="Description"\>([^\.]+)\.([^\.]+)\.*/){
								$scan=$2;
							 }
							if($line=~/\<GAML:attribute type="charge"\>([0-9]+)\<\/GAML:attribute\>/)
							{
								my $charge=$1;
								if ($reversed==0 and $expect<$threshold)
								{
									$proteins=~s/^#//;
									$proteins=~s/#$//;
									$proteins=~s/##/,/g;
									print OUT qq!$peptide\t$modifications\t$charge\t$expect\t$scan\t$intensity\t$proteins\n!;
								}
								$scan="";
								$start="";
								$expect="";
								$intensity="";
								$peptide="";
								$modifications="";
								$reversed=0;
								$proteins="";
							}
						}
						close(OUT);	
					}	
					close(IN);
				}
			}
		}
	}
}
